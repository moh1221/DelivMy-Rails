class Request < ApplicationRecord
  class Unavailable < StandardError; end

  belongs_to :user, inverse_of: :requests
  has_many :items, inverse_of: :request, dependent: :destroy
  has_one :location, inverse_of: :request, dependent: :destroy
  has_one :deliver, inverse_of: :request, dependent: :destroy
  belongs_to :category
  belongs_to :status
  has_one :profile, through: :user

  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :location, reject_if: :all_blank

  validates :PlaceName, :delivery_at, :location, presence: true
  validates :cost, :fees, numericality: { greater_than_or_equal_to: 0 }
  validates :items, length: { minimum: 1 }
  validate :delivery_is_in_future, on: :create

  scope :open, -> { where(status_id: Status::OPEN).where("delivery_at > ?", Time.current) }
  scope :for_search, ->(user) { open.where.not(user_id: user.id).joins(:location).includes(:items, :category, :location, :profile).order(id: :desc) }

  def self.in_bounds(south, west, north, east)
    bounds = Location.arel_table
    radius = Arel::Nodes.build_quoted(Location::PUBLIC_PRECISION)
    latitude = Arel::Nodes::NamedFunction.new("ROUND", [bounds[:Lat], radius])
    longitude_degrees = Arel::Nodes::NamedFunction.new("ROUND", [bounds[:Long], radius])
    longitude = if west <= east
      longitude_degrees.between(west..east)
    else
      longitude_degrees.gteq(west).or(longitude_degrees.lteq(east))
    end

    where(latitude.between(south..north).and(longitude))
  end

  def available?
    status_id == Status::OPEN && delivery_at&.future? && deliver.nil?
  end

  def readable_by?(user)
    participant?(user) || available?
  end

  def participant?(user)
    user_id == user.id || deliver&.user_id == user.id
  end

  def accept_by!(courier)
    with_lock do
      raise Unavailable, "You cannot accept your own request." if user_id == courier.id
      raise Unavailable, "This request is no longer available." unless available?

      create_deliver!(user: courier, status_id: Status::OPEN)
      update!(status_id: Status::IN_PROGRESS)
    end
    deliver
  end

  def cancel!
    with_lock do
      raise Unavailable, "An accepted request cannot be deleted." unless status_id == Status::OPEN && deliver.nil?

      destroy!
    end
  end

  private

  def delivery_is_in_future
    errors.add(:delivery_at, "must be in the future") if delivery_at && !delivery_at.future?
  end
end
