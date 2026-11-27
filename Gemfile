source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "8.1.4.1"
gem "puma", "~> 7.0"
gem "sprockets-rails", "~> 3.5"
gem "bcrypt", "~> 3.1"
gem "rack-attack", "~> 6.8"

group :development, :test do
  gem "sqlite3", "~> 2.0"
end

group :production do
  gem "mysql2", "~> 0.5"
  gem "aws-sdk-s3", "~> 1.0", require: false
end

group :test do
  gem "minitest", "~> 5.0"
end
