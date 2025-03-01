require "test_helper"

class LanguagesControllerTest < ActionDispatch::IntegrationTest
  def build_jwt(user_id)
    payload = {
      user_id: user_id,
      exp: Time.now.to_i + (7*24*60*60)
    }
    JWT.encode(payload, ENV["SECRET_KEY"] || "test key")
  end

  setup do
    @base_language = Language.create({
      name: "Python",
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    })
    @valid_language_params = {
      name: "Ruby"
    }
    @user = User.create({
      first_name: "Ringfinger",
      last_name: "leonhard",
      email: "leonhard@rosarias-fingers.com",
      password: "R1nGf|n&3r",
      avatar: file_fixture_upload("test/fixtures/files/default-avatar.jpg", "icon/jpg")
    })
    @token = build_jwt(@user.id)
  end

  test "#index returns response :ok" do
    get languages_url
    assert_response :ok
  end

  test "#index returns an array of languages that can be fetched from the database" do
    get languages_url
    body = JSON.parse(response.body)
    assert_nothing_raised {
      body.each do |language|
        Language.find(language["id"])
      end
    }
  end

  test "#index should return an array when a single language exists" do
    Language.destroy_all
    Language.create(@valid_language_params)
    get languages_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 1, body.length
  end

  test "#index should return an empty array when no languages exist" do
    Language.destroy_all
    get languages_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 0, body.length
  end

  # # ########
  # # # SHOW #
  # # ########

  # test "#show returns response :ok" do
  #   get language_url(@base_language.id)
  #   assert_response :ok
  # end

  # test "#show returns a language that can be fetched from the database" do
  #   get language_url(@base_language.id)
  #   body = JSON.parse(response.body)
  #   assert_nothing_raised {
  #     Language.find(body["id"])
  #   }
  # end

  # test "#show returns response :not_found when given an invalid language id" do
  #   get language_url(0)
  #   assert_response :not_found
  # end

  # test "#show should return error ActionController::UrlGenerationError know yet with no language id" do
  #   assert_raises(ActionController::UrlGenerationError) { show language_url }
  # end

  # # ##########
  # # # CREATE #
  # # ##########

  # test "#create should return response :unauthorized when a user with not authorization headers provided" do
  #   post languages_url, params: @valid_language_params
  #   body = JSON.parse(response.body)
  #   assert_equal "Please log in", body["message"]
  #   assert_response :unauthorized
  # end

  # test "#create should return response :unauthorized with non admin user provided" do
  #   post languages_url, params: @valid_language_params, headers: { "Authorization": "Bearer #{ @token }" }
  #   body = JSON.parse(response.body)
  #   assert_equal "Permission denied", body["message"]
  #   assert_response :unauthorized
  # end

  # test "#create should return response :ok with admin user provided" do
  #   @user.add_role :admin
  #   post languages_url, params: @valid_language_params, headers: { "Authorization": "Bearer #{ @token }" }
  #   assert_response :accepted
  # end

  # test "#create should return response :bad_request with no params provided" do
  #   @user.add_role :admin
  #   post languages_url, headers: { "Authorization": "Bearer #{ @token }" }
  #   assert_response :bad_request
  # end

  # test "#create should return a language that can be fetched from the database" do
  #   @user.add_role :admin
  #   post languages_url, params: @valid_language_params, headers: { "Authorization": "Bearer #{ @token }" }
  #   body = JSON.parse(response.body)
  #   assert_nothing_raised { Language.find(body["id"]) }
  # end

  # test "#create should return a language that matches the provided language params" do
  #   @user.add_role :admin
  #   post languages_url, params: @valid_language_params, headers: { "Authorization": "Bearer #{ @token }" }
  #   body = JSON.parse(response.body)
  #   @valid_language_params.each do |key, value|
  #     assert_equal value, body["#{ key}"]
  #   end
  # end

  # # ##########
  # # # UPDATE #
  # # ##########

  # test "#update returns response :unauthorized with no Authoriaztion headers present" do
  #   patch language_url(@base_language.id), params: @valid_language_params
  #   body = JSON.parse(response.body)
  #   assert_equal "Please log in", body["message"]
  #   assert_response :unauthorized
  # end

  # test "#update should return response :unauthorized with non admin user provided" do
  #   patch language_url(@base_language.id), params: @valid_language_params, headers: { "Authorization": "Bearer #{ @token }" }
  #   body = JSON.parse(response.body)
  #   assert_equal "Permission denied", body["message"]
  #   assert_response :unauthorized
  # end

  # test "#update should return response :accepted with admin user provided" do
  #   @user.add_role :admin
  #   patch language_url(@base_language.id), params: @valid_language_params, headers: { "Authorization": "Bearer #{ @token }" }
  #   assert_response :accepted
  # end

  # test "#update should return response :bad_request with no params provided" do
  #   @user.add_role :admin
  #   patch language_url(@base_language.id), headers: { "Authorization": "Bearer #{ @token }" }
  #   assert_response :bad_request
  # end

  # test "#update should return response :bad_request with only invalid params provided" do
  #   @user.add_role :admin
  #   patch language_url(@base_language.id), params: { length: 2589 }, headers: { "Authorization": "Bearer #{ @token }" }
  #   assert_response :bad_request
  # end

  # test "#update should return a language that matches the id of the language requested for update" do
  #   @user.add_role :admin
  #   patch language_url(@base_language.id), params: @valid_language_params, headers: { "Authorization": "Bearer #{ @token }" }
  #   body = JSON.parse(response.body)
  #   assert_equal @base_language.id, @user.id
  # end

  # test "#update should update the requested language in the database" do
  #   @user.add_role :admin
  #   patch language_url(@base_language.id), params: @valid_language_params, headers: { "Authorization": "Bearer #{ @token }" }
  #   body = JSON.parse(response.body)
  #   fetched_language = Language.find(body["id"])
  #   @valid_language_params.each do |key, value|
  #     assert_equal value, fetched_language[:"#{ key}"]
  #   end
  # end

  # # ###########
  # # # DESTROY #
  # # ###########

  # test "#destroy returns response :unauthorized with no Authoriaztion headers present" do
  #   delete language_url(@base_language.id)
  #   body = JSON.parse(response.body)
  #   assert_equal "Please log in", body["message"]
  #   assert_response :unauthorized
  # end

  # test "#destroy should return response :unauthorized with non admin user provided" do
  #   delete language_url(@base_language.id), headers: { "Authorization": "Bearer #{ @token }" }
  #   body = JSON.parse(response.body)
  #   assert_equal "Permission denied", body["message"]
  #   assert_response :unauthorized
  # end

  # test "#destroy should return response :ok with admin user provided" do
  #   @user.add_role :admin
  #   delete language_url(@base_language.id), headers: { "Authorization": "Bearer #{ @token }" }
  #   assert_response :ok
  # end

  # test "#destroy should remove a language from the database" do
  #   @user.add_role :admin
  #   assert_difference("Language.count", -1) {
  #     delete language_url(@base_language.id), headers: { "Authorization": "Bearer #{ @token }" }
  #   }
  # end

  # test "#destroy should removes specified language from the database" do
  #   @user.add_role :admin
  #   id = @base_language.id
  #   delete language_url(@base_language.id), headers: { "Authorization": "Bearer #{ @token }" }
  #   assert_raises(ActiveRecord::RecordNotFound) {
  #     Language.find(id)
  #   }
  # end

  # test "#destroy should return response :not_found with invalid language" do
  #   @user.add_role :admin
  #   delete language_url(0), headers: { "Authorization": "Bearer #{ @token }" }
  #   assert_response :not_found
  # end

  # test "#destroy should return error ActionController::UrlGenerationError with no language id" do
  #   assert_raises(ActionController::UrlGenerationError) { language_url }
  # end
end
