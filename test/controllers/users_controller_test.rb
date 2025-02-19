require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def build_jwt(user_id)
    payload = {
      user_id: user_id,
      exp: Time.now.to_i + (7*24*60*60)
    }
    JWT.encode(payload, ENV["SECRET_KEY"] || "test key")
  end

  setup do
    @valid_password = "V4LidP@ssw0rd"
    @base_user_params = {
      first_name: "Ringfinger",
      last_name: "leonhard",
      email: "leonhard@rosarias-fingers.com",
      password: "R1nGf|n&3r",
      avatar: file_fixture_upload("test/fixtures/files/default-avatar.jpg", "image/jpg")
    }
    @base_user=User.create!(@base_user_params)
    @base_user_token = build_jwt(@base_user.id)
    @valid_params = {
      first_name: "Longfinger",
      last_name: "Kirk",
      email: "kirk@rosarias-fingers.com",
      password: "|_0ngFing3r",
      avatar: file_fixture_upload("test/fixtures/files/default-avatar.jpg", "image/jpg")
    }

    @non_permitted_params = {
      armor_set: "thorns"
    }
    @invalid_email = "heysel_yellow_finger"
  end


  # #########
  # # INDEX #
  # #########

  test "#index should return response :unauthorized with no Authorization header" do
    get users_url
    assert_response :unauthorized
  end

  test "#index should return response :unauthorized with invalid Authorization header" do
    get users_url, headers: { "Authorization": "Bearer 000000" }
    assert_response :unauthorized
  end

  test "#index should return response :unauthorized when user provided does not have role :admin" do
    token = build_jwt(@base_user.id)
    get users_url, headers: { "Authorization": "Bearer #{token}" }
    assert_response :unauthorized
  end

  test "#index should return response :ok when user provided has role :admin" do
    @base_user.add_role :admin
    token = build_jwt(@base_user.id)
    get users_url, headers: { "Authorization": "Bearer #{token}" }
    assert_response :ok
  end

  test "#index should return an Array as a response" do
    @base_user.add_role :admin
    token = build_jwt(@base_user.id)
    get users_url, headers: { "Authorization": "Bearer #{token}" }
    assert_kind_of(Array, JSON.parse(response.body))
  end

  test "#index should return an array of users whose attributes does not include password or password_digest" do
    @base_user.add_role :admin
    token = build_jwt(@base_user.id)
    get users_url, headers: { "Authorization": "Bearer #{token}" }
    body = JSON.parse(response.body)
    body.each do |user|
      assert_not user.key?("password")
      assert_not user.key?("password_digest")
    end
  end

  test "#index should return an Array when single User exists" do
    User.destroy_all
    user = User.create!(@valid_params)
    user.add_role :admin
    token = build_jwt(user.id)
    get users_url, headers: { "Authorization": "Bearer #{token}" }
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 1, body.length
  end

  # ########
  # # SHOW #
  # ########

  test "#show should return response :unauthorized when a user with not authentication headers provided" do
    get user_url(@base_user.id)
    assert_response :unauthorized
  end

  test "#show should return response :unauthorized when a user with invalid authentication headers provided" do
    get user_url(@base_user.id), headers: { "Authorization": "Bearer 0000000" }
    assert_response :unauthorized
  end

  test "#show should return response :ok with valid user id and valid Authorization header" do
    token = build_jwt(@base_user.id)
    get user_url(@base_user.id), headers: { "Authorization": "Bearer #{ token }" }
    assert_response :ok
  end

  test "#show should respond with :unauthorized when requested by a user that is not the requested user" do
    secondary_user = User.create!(@valid_params)
    unauthorized_token = build_jwt(secondary_user.id)
    get user_url(@base_user.id), headers: { "Authorization": "Bearer #{ unauthorized_token }" }
    assert_response :unauthorized
  end

  test "#show should respond with :ok when requested by an admin user that is not the requested user" do
    secondary_user = User.create!(@valid_params)
    secondary_user.add_role :admin
    unauthorized_token = build_jwt(secondary_user.id)
    get user_url(@base_user.id), headers: { "Authorization": "Bearer #{ unauthorized_token }" }
    assert_response :ok
  end

  test "#show returns a User that should match requested user" do
    token = build_jwt(@base_user.id)
    get user_url(@base_user.id), headers: { "Authorization": "Bearer #{token}" }
    requested_user = JSON.parse(response.body)
    assert_equal @base_user.id, requested_user["id"].to_i
    assert_equal @base_user.email, requested_user["email"]
  end

  test "#show should return error ActionController::UrlGenerationError know yet with no user id" do
    assert_raises("ActionController::UrlGenerationError") { show user_url }
  end

  # ##########
  # # CREATE #
  # ##########

  test "#create should return response :accepted with valid params" do
    post users_url, params: @valid_params
    assert_response :accepted
  end

  test "#create should create a user with vaild params" do
    post users_url, params: @valid_params
    created_user = JSON.parse(response.body)
    fetched_user = User.find(created_user["id"])
    assert_equal created_user["id"], fetched_user.id
    assert_equal created_user["email"], fetched_user.email
  end

  test "#create should return :bad_request with invalid permitted param" do
    @valid_params[:email] = @invalid_email
    post users_url, params: @valid_params
    assert_response :bad_request
  end

  test "#create should return in response body under email key 'is invalid'" do
    @valid_params[:email] = @invalid_email
    post users_url, params: @valid_params
    body = JSON.parse(response.body)
    assert_response :bad_request
    assert(body["email"].include? "is invalid")
  end

  test "#create does not add non permitted params to returned user" do
    valid_plus_non_permitted_params = @valid_params.merge(@non_permitted_params)
    post users_url, params: valid_plus_non_permitted_params
    assert_response :accepted
  end

  test "#create should return :accepted with valid permitted params include non permitted params" do
    valid_plus_non_permitted_params = @valid_params.merge(@non_permitted_params)
    post users_url, params: valid_plus_non_permitted_params
    created_user = JSON.parse(response.body)
    @non_permitted_params.each do |key|
      assert_nil created_user[key]
    end
  end

  test "#create should return a user that has a file attached at avatar with valid params" do
    post users_url, params: @valid_params
    created_user = JSON.parse(response.body)
    fetched_user = User.find(created_user["id"])
    assert fetched_user.avatar.attached?
  end

  # ##########
  # # UPDATE #
  # ##########

  test "#update should return response :unauthorized with valid params, and no Authorization header" do
    patch user_url(@base_user.id), params: { email: @valid_params[:email] }
    assert_response :unauthorized
  end

  test "#update should return response :unauthorized with valid params, and invalid Authorization header" do
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer 0000000" }, params: { email: @valid_params[:email] }
    assert_response :unauthorized
  end

  test "#update should return response :ok with valid params, and valid Authorization header of the user requested" do
    token = build_jwt(@base_user.id)
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer #{ token }" }, params: { email: @valid_params[:email] }
    assert_response :ok
  end

  test "#update should return response :unauthorized with valid params, and valid Authorization header of a user other than the one requested" do
    other_user = User.create!(@valid_params)
    unauthorized_token = build_jwt(other_user.id)
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer #{ unauthorized_token }" }, params: { first_name: @valid_params[:first_name] }
    assert_response :unauthorized
  end

  test "#update should return response :ok with valid params, and valid admin user Authorization header" do
    admin_user = User.create!(@valid_params)
    admin_user.add_role :admin
    admin_token = build_jwt(admin_user.id)
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer #{ admin_token }" }, params: { first_name: @valid_params[:first_name] }
    assert_response :ok
  end

  test "#update should update password digest with valid password" do
    previous_digest = @base_user.password_digest
    token = build_jwt(@base_user.id)
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer #{ token }" }, params: { password: "K3epH3r$@fe" }
    updated_user = JSON.parse(response.body)
    assert_not_equal previous_digest, updated_user["password_digest"]
  end

  test "#update should update user in the database" do
    token = build_jwt(@base_user.id)
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer #{ token }" }, params: @valid_params
    updated_user = User.find(@base_user.id)
    assert_equal updated_user.email, @valid_params[:email]
  end

  test "#update should return response :unprocessable_entity with invalid params" do
    token = build_jwt(@base_user.id)
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer #{ token }" }, params: @invalid_params
    assert_response :unprocessable_entity
  end

  test "#update should return response :unprocessable_entity with empty params" do
    token = build_jwt(@base_user.id)
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer #{ token }" }, params: {}
    assert_response :unprocessable_entity
  end

  test "#update should return response :ok with non permitted params present" do
    valid_plus_non_permitted_params = @valid_params.merge(@non_permitted_params)
    token = build_jwt(@base_user.id)
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer #{ token }" }, params: valid_plus_non_permitted_params
    assert_response :ok
  end

  test "#create should return user not including non permitted params with valid permitted params" do
    valid_plus_non_permitted_params = @valid_params.merge(@non_permitted_params)
    token = build_jwt(@base_user.id)
    patch user_url(@base_user.id), headers: { "Authorization": "Bearer #{ token }" }, params: valid_plus_non_permitted_params
    updated_user = JSON.parse(response.body)
    @non_permitted_params.each do |key|
      assert_nil updated_user[key]
    end
  end

  # ###########
  # # DESTROY #
  # ###########

  test "#destroy should return response :unauthorized without valid Authorization headers" do
    delete user_url(@base_user.id)
    assert_response :unauthorized
  end

  test "#destroy should return response :unauthorized with with valid Authorization headers not matching requested user" do
    other_user = User.create!(@valid_params)
    unauthorized_token = build_jwt(other_user.id)
    delete user_url(@base_user.id), headers: { "Authorization": "Bearer #{ unauthorized_token }" }
    assert_response :unauthorized
  end

  test "#destroy should return response :unauthorized with with invalid Authorization headers" do
    delete user_url(@base_user.id), headers: { "Authorization": "Bearer 000" }
    assert_response :unauthorized
  end

  test "#destroy should return response :ok with with valid admin Authorization headers" do
    admin_user = User.create!(@valid_params)
    admin_user.add_role :admin
    admin_token = build_jwt(admin_user.id)
    delete user_url(@base_user.id), headers: { "Authorization": "Bearer #{ admin_token }" }
    assert_response :ok
  end

  test "#destroy should destroy the specified user in the database with valid Authorization headers matching requested user" do
    user_id = @base_user.id
    token = build_jwt(user_id)
    delete user_url(user_id), headers: { "Authorization": "Bearer #{token}" }
    assert_raises ("ActiveRecord::RecordNotFound") { User.find(user_id) }
  end

  test "#destroy should return response :not_found with invalid user" do
    token = build_jwt(@base_user.id)
    delete user_url(0), headers: { "Authorization": "Bearer #{token}" }
    assert_response :not_found
  end

  test "#destroy should return error ActionController::UrlGenerationError know yet with no user id" do
    assert_raises("ActionController::UrlGenerationError") { delete user_url }
  end
end
