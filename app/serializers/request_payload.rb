class RequestPayload
  def initialize(view_context)
    @view = view_context
  end

  def order(record, delivery: false, profile: false, location: false, exact_location: false)
    data = record.as_json
    data["items"] = record.items.map { |item| item.as_json(only: :id) }
    data["category"] = record.category&.as_json(only: :CatName)
    data["deliver"] = courier(record.deliver) if delivery
    data["profile"] = public_profile(record.profile) if profile
    if location
      data["location"] = exact_location ?
        record.location&.as_json(except: [:created_at, :updated_at]) : record.location&.listing_payload
    end
    data
  end

  def courier(record)
    return unless record

    record.as_json.merge("profile" => public_profile(record.profile), "receipt_img" => @view.safe_https_url(record.receipt_img))
  end

  private

  def public_profile(profile)
    return unless profile

    profile.as_json(only: [:first_name, :last_name]).merge("picture" => @view.profile_image_path(profile))
  end
end
