json.array!(@search) do |f|
  json.extract! f, :id, :PlaceName, :created_at, :cost, :fees, :delivery_at, :first_name, :last_name, :email, :CatName, :picture, :Lat, :Long, :address
  json.url searchs_url(f, format: :json)
end
