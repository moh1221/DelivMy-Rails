{ Status::OPEN => "Open", Status::IN_PROGRESS => "On Progress" }.each do |id, label|
  Status.find_or_create_by!(id: id) { |status| status.status_info = label }
end

["Fast Food", "Bakery", "Book Store", "Electronics", "Furniture", "Hair Care",
 "Hardware", "Home Goods", "Laundry", "Pet Store", "Pharmacy", "Restaurant"].each do |name|
  Category.find_or_create_by!(CatName: name)
end
