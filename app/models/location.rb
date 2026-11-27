class Location < ApplicationRecord
  PUBLIC_PRECISION = 2
  PRIVATE_ADDRESS_MESSAGE = "Exact pickup address shown after acceptance."
  belongs_to :request, inverse_of: :location
  validates :address, presence: true, length: { maximum: 255 }
  validates :Lat, numericality: { in: -90..90 }
  validates :Long, numericality: { in: -180..180 }
  def listing_payload
    {
      "id" => id, "request_id" => request_id, "address" => PRIVATE_ADDRESS_MESSAGE,
      "Lat" => self.Lat.round(PUBLIC_PRECISION), "Long" => self.Long.round(PUBLIC_PRECISION)
    }
  end
end
