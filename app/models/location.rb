class Location < ActiveRecord::Base
  belongs_to :request

  acts_as_mappable :default_units => :miles,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :Lat,
                   :lng_column_name => :Long
end
