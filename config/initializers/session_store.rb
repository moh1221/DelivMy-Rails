Rails.application.config.session_store :cookie_store, key: "_DelivMyApp_v2",
  same_site: :lax, httponly: true, secure: Rails.env.production?
