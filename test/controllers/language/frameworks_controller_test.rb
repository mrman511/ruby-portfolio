require "test_helper"

class Language::FrameworksControllerTest < ActionDispatch::IntegrationTest
  def build_jwt(user_id)
    payload = {
      user_id: user_id,
      exp: Time.now.to_i + (7*24*60*60)
    }
    JWT.encode(payload, ENV["SECRET_KEY"] || "test key")
  end

  setup do
    @base_language = Language.create!({
      name: "Python",
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    })

    @base_language_framework = Framework.create!({
      name: "Flask",
      language: @base_language,
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    })

    @valid_base_language_framework_params = {
      name: "Django",
      language: @base_language,
      icon: fixture_file_upload(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }

    @new_framework_params = {
      name: "FastAPI",
      icon: fixture_file_upload(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }

    @user = User.create({
      first_name: "Ringfinger",
      last_name: "leonhard",
      email: "leonhard@rosarias-fingers.com",
      password: "R1nGf|n&3r",
      avatar: file_fixture_upload("test/fixtures/files/default-avatar.jpg", "icon/jpg")
    })
    @token = build_jwt(@user.id)

    @other_language = Language.create!({
      name: "JavaScript",
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    })

    @other_language_framework = Framework.create!({
      name: "Express",
      language: @other_language,
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    })

    @valid_use_case_params = { name: "Server" }

    @url_prefix = "/language/#{ @base_language.id }/frameworks"
  end

  test "#index returns response :ok" do
    get @url_prefix
    assert_response :ok
  end

  test "#index returns an array of frameworks that can be fetched from the database" do
    get @url_prefix
    body = JSON.parse(response.body)
    assert_nothing_raised {
      body.each do |framework|
        Framework.find(framework["id"])
      end
    }
  end

  test "#index returns an array of frameworks that belong to the specified language" do
    get @url_prefix
    body = JSON.parse(response.body)
    assert_nothing_raised {
      body.each do |framework|
        assert_equal framework["language_id"], @base_language.id
      end
    }
  end

  test "#index should return an array when a single framework exists" do
    Framework.destroy_all
    Framework.create!(@valid_base_language_framework_params)
    get @url_prefix
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 1, body.length
  end

  test "#index should return an empty array when no frameworks exist" do
    Framework.destroy_all
    get @url_prefix
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 0, body.length
  end

  # ########
  # # SHOW #
  # ########

  test "#show returns response :ok" do
    get @url_prefix + "/#{ @base_language_framework.id }"
    assert_response :ok
  end

  test "#show returns a framework that can be fetched from the database" do
    get @url_prefix + "/#{ @base_language_framework.id }"
    body = JSON.parse(response.body)
    assert_nothing_raised {
      Framework.find(body["id"])
    }
  end

  test "#show returns response :not_found when given an invalid framework id" do
    get @url_prefix + "/0"
    assert_response :not_found
  end

  test "#show returns response :not_found provided the id of a framework that does not belong to the provided language" do
    get @url_prefix + "/#{ @other_language_framework.id }"
    assert_response :not_found
  end

  # ##########
  # # CREATE #
  # ##########

  test "#create should return response :unauthorized when a user with not authorization headers provided" do
    post @url_prefix, params: @valid_base_language_framework_params
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#create should return response :unauthorized with non admin user provided" do
    post @url_prefix, params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#create should return response :accepted with admin user provided" do
    @user.add_role :admin
    post @url_prefix, params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :accepted
  end

  test "#create should attach icon to framework" do
    @user.add_role :admin
    post @url_prefix, params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    fetched_framework = Framework.find(body["id"])
    assert fetched_framework.icon.attached?
  end

  test "#create should return response :bad_request with no params provided" do
    @user.add_role :admin
    post @url_prefix, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :bad_request
  end

  test "#create should add a framework to the database" do
    @user.add_role :admin
    assert_difference ("Framework.count") {
      post @url_prefix, params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#create should return a framework that can be fetched from the database" do
    @user.add_role :admin
    post @url_prefix, params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_nothing_raised { Framework.find(body["id"]) }
  end

  test "#create should belong to specified language" do
    @user.add_role :admin
    post @url_prefix, params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal @base_language.id, body["language_id"]
  end

  test "#create should return a framework that matches the provided framework params" do
    @user.add_role :admin
    post @url_prefix, params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    @valid_base_language_framework_params.except(:language, :icon).each do |key, value|
      assert_equal value, body["#{ key}"]
    end
  end

  # ##########
  # # UPDATE #
  # ##########

  test "#update returns response :unauthorized with no Authorization headers present" do
    patch @url_prefix + "/#{ @base_language_framework.id }", params: @valid_base_language_framework_params
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#update should return response :unauthorized with non admin user provided" do
    patch @url_prefix + "/#{ @base_language_framework.id }", params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#update should return response :accepted with admin user provided" do
    @user.add_role :admin
    patch @url_prefix + "/#{ @base_language_framework.id }", params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :accepted
  end

  test "#update should return response :not_found with provided language that does not match frameworks language" do
    @user.add_role :admin
    patch @url_prefix + "/#{ @other_language_framework.id }", params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#update should return response :bad_request with no params provided" do
    @user.add_role :admin
    patch @url_prefix + "/#{ @base_language_framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :bad_request
  end

  test "#update should return response :bad_request with only invalid params provided" do
    @user.add_role :admin
    patch @url_prefix + "/#{ @base_language_framework.id }", params: { length: 2589 }, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :bad_request
  end

  test "#update should return a framework that matches the id of the framework requested for update" do
    @user.add_role :admin
    patch @url_prefix + "/#{ @base_language_framework.id }", params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal @base_language_framework.id, @user.id
  end

  test "#update should update the requested framework in the database" do
    @user.add_role :admin
    patch @url_prefix + "/#{ @base_language_framework.id }", params: @valid_base_language_framework_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    fetched_framework = Framework.find(body["id"])
    @valid_base_language_framework_params.except(:language, :icon).each do |key, value|
      assert_equal value, fetched_framework[:"#{ key}"]
    end
  end

  # ###########
  # # DESTROY #
  # ###########

  test "#destroy returns response :unauthorized with no Authoriaztion headers present" do
    delete @url_prefix + "/#{ @base_language_framework.id }"
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#destroy should return response :unauthorized with non admin user provided" do
    delete "/language/#{@base_language.id }/frameworks/#{ @base_language_framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#destroy should return response :ok with admin user provided" do
    @user.add_role :admin
    delete @url_prefix + "/#{ @base_language_framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :ok
  end

  test "#destroy should return response :not_found when the requested language does not match the frameworks language" do
    @user.add_role :admin
    delete @url_prefix + "/#{ @other_language_framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#destroy should remove a framework from the database" do
    @user.add_role :admin
    assert_difference("Framework.count", -1) {
      delete @url_prefix + "/#{ @base_language_framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#destroy should removes specified framework from the database" do
    @user.add_role :admin
    id = @base_language_framework.id
    delete @url_prefix + "/#{ @base_language_framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_raises(ActiveRecord::RecordNotFound) {
      Framework.find(id)
    }
  end

  test "#destroy should return response :not_found with invalid framework" do
    @user.add_role :admin
    delete @url_prefix + "/#{ 0 }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  # ################
  # # ADD USE CASE #
  # ################

  test "#add_use_case returns response :unauthorized with no Authoriaztion headers present" do
    post @url_prefix + "/#{ @base_language_framework.id }/add_use_case", params: @valid_use_case_params
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#add_use_case should return response :unauthorized with non admin user provided" do
    post @url_prefix + "/#{ @base_language_framework.id }/add_use_case", params: @valid_use_case_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#add_use_case should return response :accepted with admin user provided and params provided" do
    @user.add_role :admin
    post @url_prefix + "/#{ @base_language_framework.id }/add_use_case", params: @valid_use_case_params, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :accepted
  end

  test "#add_use_case should return response :not_found when the requested language does not match the frameworks language" do
    @user.add_role :admin
    post @url_prefix + "/#{ @other_language_framework.id }/add_use_case", params: @valid_use_case_params, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#add_use_case should return response :bad_request with no valid params" do
    @user.add_role :admin
    post @url_prefix + "/#{ @base_language_framework.id }/add_use_case", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :bad_request
  end

  test "#add_use_case adds a UseCase to framework use_cases" do
    @user.add_role :admin
    assert_difference("@base_language_framework.use_cases.count") {
      post @url_prefix + "/#{ @base_language_framework.id }/add_use_case", params: @valid_use_case_params, headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#add_use_case returns the requested framework" do
    @user.add_role :admin
    post @url_prefix + "/#{ @base_language_framework.id }/add_use_case", params: @valid_use_case_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal body["id"], @base_language_framework.id
  end

  # ###################
  # # REMOVE USE CASE #
  # ###################

  test "#remove_use_case returns response :unauthorized with no Authoriaztion headers present" do
    use_case = UseCase.create!(@valid_use_case_params)
    @base_language_framework.add_use_case(name: use_case.name)
    delete @url_prefix + "/#{ @base_language_framework.id }/remove_use_case/#{ use_case.id }"
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#remove_use_case should return response :unauthorized with non admin user provided" do
    use_case = UseCase.create!(@valid_use_case_params)
    @base_language_framework.add_use_case(name: use_case.name)
    delete @url_prefix + "/#{ @base_language_framework.id }/remove_use_case/#{ use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#remove_use_case should return response :accepted with admin user provided and use_case_id provided" do
    use_case = UseCase.create!(@valid_use_case_params)
    @base_language_framework.add_use_case(name: use_case.name)
    @user.add_role :admin
    delete @url_prefix + "/#{ @base_language_framework.id }/remove_use_case/#{ use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :accepted
  end

  test "#remove_use_case should return response :not_found when the requested language does not match the frameworks language" do
    use_case = UseCase.create!(@valid_use_case_params)
    @base_language_framework.add_use_case(name: use_case.name)
    @user.add_role :admin
    delete @url_prefix + "/#{ @other_language_framework.id }/remove_use_case/#{ use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#remove_use_case should return response :not_found with invalid use_case_id" do
    @user.add_role :admin
    delete @url_prefix + "/#{ @base_language_framework.id }/remove_use_case/0", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#remove_use_case removes a UseCase from framework use_cases" do
    use_case = UseCase.create!(@valid_use_case_params)
    @base_language_framework.add_use_case(name: use_case.name)
    @user.add_role :admin
    assert_difference("@base_language_framework.use_cases.count", -1) {
      delete @url_prefix + "/#{ @base_language_framework.id }/remove_use_case/#{ use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#remove_use_case returns the requested framework" do
    use_case = UseCase.create!(@valid_use_case_params)
    @base_language_framework.add_use_case(name: use_case.name)
    @user.add_role :admin
    delete @url_prefix + "/#{ @base_language_framework.id }/remove_use_case/#{ use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal body["id"], @base_language_framework.id
  end
end
