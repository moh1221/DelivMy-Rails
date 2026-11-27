require "test_helper"

class DeliveryWorkflowTest < ActionDispatch::IntegrationTest
  PASSWORD = "local-test-password"

  setup do
    @owner = account("owner")
    @courier = account("courier")
    @other = account("other")
    @category = Category.find_or_create_by!(CatName: "Groceries")
    Status.find_or_create_by!(id: Status::OPEN) { |status| status.status_info = "Open" }
    Status.find_or_create_by!(id: Status::IN_PROGRESS) { |status| status.status_info = "On Progress" }
  end

  test "anonymous callers cannot see requests or delivery data" do
    order = @owner.requests.create!(order_data.merge(status_id: Status::OPEN))
    %W[/requests.json /search.json /delivers.json /delivers/#{order.id}.json
       /requests/#{order.id}.json /requests/#{order.id}/items.json
       /requests/#{order.id}/locations.json].each do |path|
      get path
      assert_response :unauthorized, path
      assert_equal "Sign in required.", response.parsed_body["error"]
    end
    delete "/requests/#{order.id}.json"
    assert_response :unauthorized
    assert Request.exists?(order.id)
  end

  test "native login, nearby search, acceptance, and restricted completed details" do
    owner_headers = sign_in(@owner)
    courier_headers = sign_in(@courier)
    other_headers = sign_in(@other)

    post "/requests.json", params: { request: order_data }, headers: owner_headers, as: :json
    assert_response :created
    order_id = response.parsed_body.fetch("id")
    assert_equal @owner.id, response.parsed_body["user_id"]
    assert_equal Status::OPEN, response.parsed_body["status_id"]
    assert_equal BigDecimal("12.50"), BigDecimal(response.parsed_body["cost"].to_s)
    assert_equal 1, response.parsed_body.fetch("items").length

    get "/requests.json", headers: owner_headers
    assert_response :ok
    assert_equal [order_id], response.parsed_body.pluck("id")

    get "/search.json", params: { sw: "38,-78", ne: "40,-76", center: "39,-77" }, headers: courier_headers
    assert_response :ok
    order = response.parsed_body.fetch(0)
    assert_equal order_id, order["id"]
    assert_equal @category.CatName, order.fetch("category").fetch("CatName")
    assert_equal 39.12, order.fetch("location").fetch("Lat")
    assert_equal Location::PRIVATE_ADDRESS_MESSAGE, order.fetch("location").fetch("address")
    get "/requests/#{order_id}/locations.json", headers: courier_headers
    assert_response :ok
    assert_equal Location::PRIVATE_ADDRESS_MESSAGE, response.parsed_body.fetch("address")
    assert_equal %w[first_name last_name picture], order.fetch("profile").keys.sort
    get "/search.json", params: { sw: "0,0", ne: "1,1" }, headers: courier_headers
    assert_response :ok
    assert_empty response.parsed_body
    get "/search.json", params: { sw: "bad", ne: "1,1" }, headers: courier_headers
    assert_response :bad_request

    get "/requests/#{order_id}/items.json", headers: courier_headers
    assert_response :ok
    assert_equal "Milk", response.parsed_body.fetch(0).fetch("ItemsName")

    delete "/requests/#{order_id}.json", headers: other_headers
    assert_response :not_found
    post "/delivers/new.json", params: { request_id: order_id }, headers: owner_headers, as: :json
    assert_response :conflict
    post "/delivers/new.json", params: { request_id: order_id }, headers: courier_headers, as: :json
    assert_response :ok
    assert_equal "Success", response.parsed_body.fetch("message")
    post "/delivers/new.json", params: { request_id: order_id }, headers: other_headers, as: :json
    assert_response :conflict
    assert_equal 1, Deliver.where(request_id: order_id).count
    assert_equal Status::IN_PROGRESS, Request.find(order_id).status_id

    delete "/requests/#{order_id}.json", headers: owner_headers
    assert_response :conflict
    %W[/requests/#{order_id}/items.json /requests/#{order_id}/locations.json /delivers/#{order_id}.json].each do |path|
      get path, headers: other_headers
      assert_response :not_found, path
    end
    get "/requests/#{order_id}/locations.json", headers: courier_headers
    assert_response :ok
    assert_equal "123 Test Pickup", response.parsed_body["address"]

    get "/delivers.json", headers: courier_headers
    assert_response :ok
    assert_equal [order_id], response.parsed_body.pluck("id")
    assert_equal @courier.id, response.parsed_body.first.fetch("deliver").fetch("user_id")
    assert_equal %w[first_name last_name picture], response.parsed_body.first.fetch("deliver").fetch("profile").keys.sort
    get "/delivers.json", headers: other_headers
    assert_response :ok
    assert_empty response.parsed_body
  end

  test "dateline search is inclusive and only sees open requests scheduled in the future" do
    orders = [179, -179, 0].map do |longitude|
      data = order_data
      data[:location_attributes][:Long] = longitude
      @owner.requests.create!(data.merge(status_id: Status::OPEN))
    end
    orders.first.update_column(:delivery_at, Time.current - 10.minutes)
    get "/search.json", params: { sw: "38,170", ne: "40,-170" }, headers: sign_in(@courier)
    assert_response :ok
    assert_equal [orders[1].id], response.parsed_body.pluck("id")
  end

  test "only the actual owner may create and then cancel an open request" do
    headers = sign_in(@owner)
    data = order_data.merge(user_id: @other.id, status_id: Status::IN_PROGRESS)
    post "/requests.json", params: { request: data }, headers: headers, as: :json
    assert_response :created
    order_id = response.parsed_body.fetch("id")
    assert_equal @owner.id, response.parsed_body.fetch("user_id")
    assert_equal Status::OPEN, response.parsed_body.fetch("status_id")
    delete "/requests/#{order_id}.json", headers: headers
    assert_response :no_content
    assert_not Request.exists?(order_id)
    assert_not Item.exists?(request_id: order_id)
    assert_not Location.exists?(request_id: order_id)
  end

  test "unknown credentials and expired or revoked API sessions are rejected" do
    post "/login.json", params: { session: { email: "missing@example.test", password: PASSWORD } }, as: :json
    assert_response :unauthorized
    assert_equal "Invalid email or password.", response.parsed_body.fetch("error")
    first_headers = sign_in(@owner)
    second_headers = sign_in(@owner)
    delete "/logout.json", headers: first_headers
    assert_response :no_content
    get "/requests.json", headers: first_headers
    assert_response :unauthorized
    get "/requests.json", headers: second_headers
    assert_response :ok
    @owner.authentication_sessions.update_all(expires_at: 1.minute.ago)
    get "/requests.json", headers: second_headers
    assert_response :unauthorized
  end

  test "password reset is single use, stores only a digest and ends current sessions" do
    headers = sign_in(@owner)
    assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
      post "/password_resets", params: { email: @owner.email }
    end
    assert_redirected_to root_path
    body = ActionMailer::Base.deliveries.last.text_part.body.decoded
    token = body[%r{/password_resets/edit\?token=([A-Za-z0-9_-]+)}, 1]
    assert_not_nil token
    assert_not_equal token, @owner.reload.password_reset_token
    assert_equal AuthenticationSession.digest(token), @owner.password_reset_token

    get "/password_resets/edit", params: { token: token }
    assert_response :ok
    patch "/password_resets", params: { token: token, user: { password: "a-new-password", password_confirmation: "a-new-password" } }
    assert_redirected_to login_path
    assert_nil @owner.reload.password_reset_token
    assert @owner.authenticate("a-new-password")
    get "/password_resets/edit", params: { token: token }
    assert_response :not_found
    get "/requests.json", headers: headers
    assert_response :unauthorized
  end

  test "browser can open registration, sign in, browse, and render request form" do
    get "/"
    assert_response :ok
    assert_select 'link[href*="bootstrap.min"]'
    get "/signup"
    assert_response :ok
    assert_select 'form[action="/users"]'
    post "/login", params: { session: { email: @owner.email, password: PASSWORD } }
    assert_redirected_to search_path
    %w[/requests/new /requests /search /delivers /profiles /uploads/new /user].each do |path|
      get path
      assert_response :ok, path
    end
    get "/requests/new"
    assert_select "template#request-item-template"
    assert_select '[name="request[location_attributes][Lat]"]'
  end

  test "browser form keeps each dynamically indexed item" do
    post "/login", params: { session: { email: @owner.email, password: PASSWORD } }
    data = order_data.merge(items_attributes: {
      "0" => { ItemsName: "Apples", ItemDescription: "One bag" },
      "1795759200000" => { ItemsName: "Bread", ItemDescription: "One loaf" }
    })
    post "/requests", params: { request: data }
    assert_redirected_to requests_path
    assert_equal ["Apples", "Bread"], @owner.requests.last.items.order(:id).map(&:ItemsName)
  end

  test "browser mutations require CSRF while explicit native bearer sessions are accepted" do
    Rails.application.config.action_controller.allow_forgery_protection = true
    ApplicationController.allow_forgery_protection = true
    SessionsController.allow_forgery_protection = true
    RequestsController.allow_forgery_protection = true
    get "/login"
    csrf = response.headers.fetch("XSRF-TOKEN")
    post "/login", params: { session: { email: @owner.email, password: PASSWORD } }, headers: { "X-CSRF-Token" => csrf }
    assert_redirected_to search_path
    post "/requests.json", params: { request: order_data }, as: :json
    assert_response :forbidden
    get "/requests/new"
    csrf = css_select('meta[name="csrf-token"]').first["content"]
    post "/requests.json", params: { request: order_data }, headers: { "X-CSRF-Token" => csrf }, as: :json
    assert_response :created

    native = open_session
    native.post "/login.json", params: { session: { email: @courier.email, password: PASSWORD } }, as: :json
    assert_equal 200, native.response.status
    token = native.response.parsed_body.fetch("session").fetch("id")
    native.post "/requests.json", params: { request: order_data }, headers: { "Authorization" => "Bearer #{token}" }, as: :json
    assert_equal 201, native.response.status
  ensure
    Rails.application.config.action_controller.allow_forgery_protection = false
    ApplicationController.allow_forgery_protection = false
    SessionsController.allow_forgery_protection = false
    RequestsController.allow_forgery_protection = false
  end

  test "profile avatar must be an accepted image file and is served via local storage" do
    post "/login", params: { session: { email: @owner.email, password: PASSWORD } }
    rejected_path = Rails.root.join("test/fixtures/files/not_an_image.txt")
    post "/uploads/new", params: { file: Rack::Test::UploadedFile.new(rejected_path, "text/plain") }
    assert_redirected_to new_uploads_path
    assert_not @owner.profile.avatar.attached?
    post "/uploads/new", params: { file: Rack::Test::UploadedFile.new(Rails.root.join("app/assets/images/user.jpg"), "image/jpeg", true) }
    assert_redirected_to profile_path
    assert @owner.profile.reload.avatar.attached?
    follow_redirect!
    assert_response :ok
    assert_select "img[src^='/rails/active_storage/']"
    path = css_select(%q{img[src^="/rails/active_storage/blobs/proxy/"]}).first["src"]
    get path
    assert_response :ok
    assert_equal "image/jpeg", response.media_type
  end

  private

  def account(name)
    User.create!(email: "#{name}@example.test", password: PASSWORD, profile_attributes: {
      first_name: name.capitalize, last_name: "Tester", home: "Private home address", work: "Private work address"
    })
  end

  def order_data
    { PlaceName: "Corner Store", category_id: @category.id, cost: "12.50", fees: "3.00",
      delivery_at: 1.day.from_now.iso8601, items_attributes: [{ ItemsName: "Milk", ItemDescription: "One carton" }],
      location_attributes: { address: "123 Test Pickup", Lat: 39.12345, Long: -77.54321 } }
  end

  def sign_in(user)
    post "/login.json", params: { session: { email: user.email, password: PASSWORD } }, as: :json
    assert_response :ok
    assert_equal user.id, response.parsed_body.fetch("session").fetch("user_id")
    token = response.parsed_body.fetch("session").fetch("id")
    assert_not AuthenticationSession.exists?(token_digest: token)
    { "Authorization" => "Bearer #{token}" }
  end
end
