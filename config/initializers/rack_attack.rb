class Rack::Attack
  unless Rails.env.test?
    throttle("authentication/ip", limit: 20, period: 5.minutes) do |request|
      request.ip if request.post? && %w[/login /signup /users /password_resets].include?(request.path.sub(/\.json\z/, ""))
    end

    throttle("avatar-upload/ip", limit: 15, period: 5.minutes) do |request|
      request.ip if request.post? && request.path == "/uploads/new"
    end
  end
end
