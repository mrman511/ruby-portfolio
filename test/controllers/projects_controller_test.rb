require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  def build_jwt(user_id)
    payload = {
      user_id: user_id,
      exp: Time.now.to_i + (7*24*60*60)
    }
    JWT.encode(payload, ENV["SECRET_KEY"] || "test key")
  end

  setup do
    @language = Language.create!(name: "Ruby")
    @framework = Framework.create!(name: "Ruby on Rails", language: @language)
    @use_case = UseCase.create!(name: "Server")
    @base_project = Project.create({
      title: "Pillpopper",
      description: "Lighthouse labs bootcamp final project",
      github_url: "https://github.com",
      live_url: "pillpopper.ca",
      role: "Co-creator",
      image: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    })
    @valid_project_params = {
      title: "Pilper",
      description: "Lighthouse labs bootcamp final project we could have done better",
      github_url: "https://github.com/mrman511",
      live_url: "pipopper.com",
      role: "Creator"
    }
    @user = User.create({
      first_name: "Ringfinger",
      last_name: "leonhard",
      email: "leonhard@rosarias-fingers.com",
      password: "R1nGf|n&3r",
      avatar: file_fixture_upload("test/fixtures/files/default-avatar.jpg", "image/jpg")
    })
    @token = build_jwt(@user.id)
  end

  test "#index returns response :ok" do
    get projects_url
    assert_response :ok
  end

  test "#index returns an array of projects that can be fetched from the database" do
    get projects_url
    body = JSON.parse(response.body)
    assert_nothing_raised {
      body.each do |project|
        Project.find(project["id"])
      end
    }
  end

  test "#index should return an array when a single project exists" do
    Project.destroy_all
    Project.create(@valid_project_params)
    get projects_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 1, body.length
  end

  test "#index should return an empty array when no projects exist" do
    Project.destroy_all
    get projects_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 0, body.length
  end

  # ########
  # # SHOW #
  # ########

  test "#show returns response :ok" do
    get project_url(@base_project.id)
    assert_response :ok
  end

  test "#show returns a project that can be fetched from the database" do
    get project_url(@base_project.id)
    body = JSON.parse(response.body)
    assert_nothing_raised {
      Project.find(body["id"])
    }
  end

  test "#show returns response :not_found when given an invalid project id" do
    get project_url(0)
    assert_response :not_found
  end

  test "#show should return error ActionController::UrlGenerationError know yet with no project id" do
    assert_raises(ActionController::UrlGenerationError) { show project_url }
  end

  # ##########
  # # CREATE #
  # ##########

  test "#create should return response :unauthorized when a user with not authorization headers provided" do
    post projects_url, params: @valid_project_params
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#create should return response :unauthorized with non admin user provided" do
    post projects_url, params: @valid_project_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#create should return response :ok with admin user provided" do
    @user.add_role :admin
    post projects_url, params: @valid_project_params, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :ok
  end

  test "#create should return response :bad_request with no params provided" do
    @user.add_role :admin
    post projects_url, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :bad_request
  end

  test "#create should return a project that can be fetched from the database" do
    @user.add_role :admin
    post projects_url, params: @valid_project_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_nothing_raised { Project.find(body["id"]) }
  end

  test "#create should return a project that matches the provided project params" do
    @user.add_role :admin
    post projects_url, params: @valid_project_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    @valid_project_params.each do |key, value|
      assert_equal value, body["#{ key}"]
    end
  end

  # ##########
  # # UPDATE #
  # ##########

  test "#update returns response :unauthorized with no Authoriaztion headers present" do
    patch project_url(@base_project.id), params: @valid_project_params
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#update should return response :unauthorized with non admin user provided" do
    patch project_url(@base_project.id), params: @valid_project_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#update should return response :ok with admin user provided" do
    @user.add_role :admin
    patch project_url(@base_project.id), params: @valid_project_params, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :ok
  end

  test "#update should return response :bad_request with no params provided" do
    @user.add_role :admin
    patch project_url(@base_project.id), headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :bad_request
  end

  test "#update should return response :bad_request with only invalid params provided" do
    @user.add_role :admin
    patch project_url(@base_project.id), params: { length: 2589 }, headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :bad_request
  end

  test "#update should return a project that matches the id of the project requested for update" do
    @user.add_role :admin
    patch project_url(@base_project.id), params: @valid_project_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal @base_project.id, @user.id
  end

  test "#update should update the requested project in the database" do
    @user.add_role :admin
    patch project_url(@base_project.id), params: @valid_project_params, headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    fetched_project = Project.find(body["id"])
    @valid_project_params.each do |key, value|
      assert_equal value, fetched_project[:"#{ key}"]
    end
  end

  # #################
  # # ADD FRAMEWORK #
  # #################

  test "#add_framework should return response :unauthorized when a user with not authorization headers provided" do
    post "/project/#{ @base_project.id }/framework/#{ @framework.id }"
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#add_framework should return response :unauthorized with non admin user provided" do
    post "/project/#{ @base_project.id }/framework/#{ @framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#add_framework should return response :ok with admin user provided" do
    @user.add_role :admin
    post "/project/#{ @base_project.id }/framework/#{ @framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :ok
  end

  test "#add_framework should return response :not_found with no framework_id" do
    @user.add_role :admin
    post "/project/#{ @base_project.id }/framework", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#add_framework should return response :not_found with invalid framework_id" do
    @user.add_role :admin
    post "/project/#{ @base_project.id }/framework/0", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#add_framework adds a framework to requested projects frameworks" do
    @user.add_role :admin
    assert_difference("@base_project.frameworks.count") {
      post "/project/#{ @base_project.id }/framework/#{ @framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#add_framework adds specified framework to requested projects frameworks" do
    @user.add_role :admin
    post "/project/#{ @base_project.id }/framework/#{ @framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    framework_present = false
    @base_project.frameworks.each do | framework |
      if framework.id == @framework.id
        framework_present = true
      end
    end
    assert framework_present
  end

  # ####################
  # # REMOVE FRAMEWORK #
  # ####################

  test "#remove_framework should return response :unauthorized when a user with not authorization headers provided" do
    @base_project.add_framework(@framework.id)
    delete "/project/#{ @base_project.id }/framework/#{ @framework.id }"
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#remove_framework should return response :unauthorized with non admin user provided" do
    @base_project.add_framework(@framework.id)
    delete "/project/#{ @base_project.id }/framework/#{ @framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#remove_framework should return response :ok with admin user provided" do
    @base_project.add_framework(@framework.id)
    @user.add_role :admin
    delete "/project/#{ @base_project.id }/framework/#{ @framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :ok
  end

  test "#remove_framework should return response :not_found with no framework_id" do
    @base_project.add_framework(@framework.id)
    @user.add_role :admin
    delete "/project/#{ @base_project.id }/framework", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#remove_framework should return response :not_found with invalid framework_id" do
    @base_project.add_framework(@framework.id)
    @user.add_role :admin
    delete "/project/#{ @base_project.id }/framework/0", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#remove_framework removes a framework from requested projects frameworks" do
    @base_project.add_framework(@framework.id)
    @user.add_role :admin
    assert_difference("@base_project.frameworks.count", -1) {
      delete "/project/#{ @base_project.id }/framework/#{ @framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#remove_framework removes specified framework to requested projects frameworks" do
    @base_project.add_framework(@framework.id)
    @user.add_role :admin
    delete "/project/#{ @base_project.id }/framework/#{ @framework.id }", headers: { "Authorization": "Bearer #{ @token }" }
    framework_present = false
    @base_project.frameworks.each do | framework |
      if framework.id == @framework.id
        framework_present = true
      end
    end
    assert_not framework_present
  end

  # ##########################
  # # ADD FRAMEWORK USE CASE #
  # ##########################

  test "#add_framework_use_case should return response :unauthorized when a user with not authorization headers provided" do
    post "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.name }"
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#add_framework_use_case should return response :unauthorized with non admin user provided" do
    post "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.name }", headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#add_framework_use_case should return response :ok with admin user provided" do
    @user.add_role :admin
    @base_project.add_framework(@framework.id)
    post "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.name }", headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_response :ok
    end

  test "#add_framework_use_case should return response :not_found when project does not have requested framework" do
    @user.add_role :admin
    post "/project/#{ @base_project.id }/framework/#{ @framework_id }/use_case/#{ @use_case.name }", headers: { "Authorization": "Bearer #{ @token }" }
    assert body["message"],  "project does not have relationship with requested framework"
    assert_response :not_found
  end

  test "#add_framework_use_case adds a ProjectFrameworkUseCase to the database" do
    @user.add_role :admin
    project_framework = @base_project.add_framework(@framework.id)
    assert_difference("ProjectFrameworkUseCase.count") {
      post "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.name }", headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#add_framework_use_case adds a use_case to requested project_framework use_cases" do
    @user.add_role :admin
    project_framework = @base_project.add_framework(@framework.id)
    assert_difference("project_framework.use_cases.count") {
      post "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.name }", headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#add_framework_use_case adds specified use_case to requested projects_framework" do
    @user.add_role :admin
    project_framework = @base_project.add_framework(@framework.id)
    post "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.name }", headers: { "Authorization": "Bearer #{ @token }" }
    use_case_present = false
    project_framework.use_cases.each do | use_case |
      if use_case.id == @use_case.id
        use_case_present = true
      end
    end
    assert use_case_present
  end

  # #############################
  # # REMOVE FRAMEWORK USE CASE #
  # #############################


  test "#remove_framework_use_case should return response :unauthorized when a user with not authorization headers provided" do
    project_framework = @base_project.add_framework(@framework.id)
    project_framework.add_use_case(@use_case.name)
    delete "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.id }"
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#remove_framework_use_case should return response :unauthorized with non admin user provided" do
    project_framework = @base_project.add_framework(@framework.id)
    project_framework.add_use_case(@use_case.name)
    delete "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#remove_framework_use_case should return response :ok with admin user provided" do
    @user.add_role :admin
    project_framework = @base_project.add_framework(@framework.id)
    project_framework.add_use_case(@use_case.name)
    delete "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :ok
  end

  test "#remove_framework_use_case should return response :not_found with no use_case_id" do
    @user.add_role :admin
    project_framework = @base_project.add_framework(@framework.id)
    project_framework.add_use_case(@use_case.name)
    delete "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/", headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#remove_framework_use_case removes a use_case from requested project_framework.use_cases" do
    @user.add_role :admin
    project_framework = @base_project.add_framework(@framework.id)
    project_framework.add_use_case(@use_case.name)
    assert_difference("project_framework.use_cases.count", -1) {
      delete "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#remove_framework_use_case removes a ProjectFrameworkUseCase from the database" do
    @user.add_role :admin
    project_framework = @base_project.add_framework(@framework.id)
    project_framework.add_use_case(@use_case.name)
    assert_difference("ProjectFrameworkUseCase.count", -1) {
      delete "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#remove_framework_use_case removes specified use_case from requested project_framework" do
    @user.add_role :admin
    project_framework = @base_project.add_framework(@framework.id)
    project_framework.add_use_case(@use_case.name)
    delete "/project/#{ @base_project.id }/framework/#{ @framework.id }/use_case/#{ @use_case.id }", headers: { "Authorization": "Bearer #{ @token }" }
    use_case_present = false
    project_framework.use_cases.each do | use_case |
      if use_case.id == @use_case.id
        use_case_present = true
      end
    end
    assert_not use_case_present
  end

  # ###########
  # # DESTROY #
  # ###########

  test "#destroy returns response :unauthorized with no Authoriaztion headers present" do
    delete project_url(@base_project.id)
    body = JSON.parse(response.body)
    assert_equal "Please log in", body["message"]
    assert_response :unauthorized
  end

  test "#destroy should return response :unauthorized with non admin user provided" do
    delete project_url(@base_project.id), headers: { "Authorization": "Bearer #{ @token }" }
    body = JSON.parse(response.body)
    assert_equal "Permission denied", body["message"]
    assert_response :unauthorized
  end

  test "#destroy should return response :ok with admin user provided" do
    @user.add_role :admin
    delete project_url(@base_project.id), headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :ok
  end

  test "#destroy should remove a project from the database" do
    @user.add_role :admin
    assert_difference("Project.count", -1) {
      delete project_url(@base_project.id), headers: { "Authorization": "Bearer #{ @token }" }
    }
  end

  test "#destroy should removes specified project from the database" do
    @user.add_role :admin
    id = @base_project.id
    delete project_url(@base_project.id), headers: { "Authorization": "Bearer #{ @token }" }
    assert_raises(ActiveRecord::RecordNotFound) {
      Project.find(id)
    }
  end

  test "#destroy should return response :not_found with invalid project" do
    @user.add_role :admin
    delete project_url(0), headers: { "Authorization": "Bearer #{ @token }" }
    assert_response :not_found
  end

  test "#destroy should return error ActionController::UrlGenerationError with no project id" do
    assert_raises(ActionController::UrlGenerationError) { project_url }
  end
end
