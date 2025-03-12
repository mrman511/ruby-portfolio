require "test_helper"

class FrameworkTest < ActiveSupport::TestCase
  setup do
    @language = Language.create!({ name: "Ruby" })
    @valid_framework_params = {
      name: "ruby on rails",
      language: @language,
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }
    @use_case = UseCase.create!(name: "Server")
    @project = Project.create!(
      title: "Portfolio",
      description: "A website to display all of my previous projects and achievement's",
      github_url: "https://github.com/mrman511",
      role: "Creator"
    )
  end

  # ##########
  # # CREATE #
  # ##########

  test "#create adds a framework to the data base with valid params" do
    assert_difference("Framework.count") {
      Framework.create!(@valid_framework_params)
    }
  end

  test "#create creates a framework that can be retrieved from the database" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_nothing_raised { Framework.find(created_framework.id) }
  end

  # # ########
  # # # NAME #
  # # ########

  test "#name is a required attribute" do
    assert_raises(ActiveRecord::RecordInvalid) {
      Framework.create!(@valid_framework_params.except(:name))
    }
  end

  test "#name is titleized when Framework is created" do
    framework = Framework.create!(@valid_framework_params)
    assert_not_equal @valid_framework_params[:name], framework.name
    assert_equal @valid_framework_params[:name].titleize, framework.name
  end

  test "#name must be unique" do
    Framework.create!(@valid_framework_params)
    assert_raises(ActiveRecord::RecordInvalid) {
      Framework.create!(@valid_framework_params)
    }
  end

  # # ########
  # # # icon #
  # # ########

  test "#icon is a file attachment" do
    created_framework = Framework.create!(@valid_framework_params)
    assert created_framework.icon.attached?
  end

  test "#icon can be attached after framework has been instantiated" do
    created_framework = Framework.create!(@valid_framework_params.except(:icon))
    created_framework.icon.attach(@valid_framework_params[:icon])
    assert created_framework.icon.attached?
  end

  test "#icon can be removed" do
    created_framework = Framework.create!(@valid_framework_params)
    created_framework.icon.purge
    assert_not created_framework.icon.attached?
  end

  # ################
  # # ADD USE CASE #
  # ################

  test "#add_use_case creates a FrameworkUseCase with a valid UseCase name" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_difference("FrameworkUseCase.count") {
      created_framework.add_use_case(name: "API")
    }
  end

  test "#add_use_case creates a new UseCase with a valid params that do not belong to a current UseCase" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_difference("UseCase.count") {
      created_framework.add_use_case(name: "API")
    }
  end

  test "#add_use_case adds a UseCase to framework.use_cases with a valid params that do not belong to a current UseCase" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_difference("created_framework.use_cases.count") {
      created_framework.add_use_case(name: "API")
    }
  end

  test "#add_use_case does not create a new UseCase if params already exist as a UseCase" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_difference("UseCase.count", 0) {
      created_framework.add_use_case(name: @use_case.name)
    }
  end

  test "#add_use_case does not create a new UseCase if params already exist as a UseCase but name is entered as lower case" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_difference("UseCase.count", 0) {
      created_framework.add_use_case(name: @use_case.name.downcase)
    }
  end

  test "#add_use_case creates a new FrameworkUseCase if params already exist as a UseCase" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_difference("FrameworkUseCase.count") {
      created_framework.add_use_case(name: @use_case.name)
    }
  end

  test "#add_use_case adds a UseCase framework.use_cases if params already exist as a UseCase" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_difference("created_framework.use_cases.count") {
      created_framework.add_use_case(name: @use_case.name)
    }
  end

  # ############
  # # PROJECTS #
  # ############

  test "#projects can be added to frameworks through ProjectFrameworks" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_difference("created_framework.projects.count") {
      ProjectFramework.create!(project: @project, framework: created_framework)
    }
  end

  # ###################
  # # REMOVE USE CASE #
  # ###################

  test "#remove_use_case Destroys a FrameworkUseCase in the data base with valid UseCase that belongs with matching framework" do
    created_framework = Framework.create!(@valid_framework_params)
    created_framework.add_use_case(name: @use_case.name)
    assert_difference("FrameworkUseCase.count", -1) {
      created_framework.remove_use_case(@use_case.id)
    }
  end

  test "#remove_use_case removes a UseCase from framework.use_cases with valid UseCase that belongs with matching framework" do
    created_framework = Framework.create!(@valid_framework_params)
    created_framework.add_use_case(name: @use_case.name)
    assert_difference("created_framework.use_cases.count", -1) {
      created_framework.remove_use_case(@use_case.id)
    }
  end

  test "#remove_use_case raises with valid UseCase that does not belong to the framework" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_raises(ActiveRecord::RecordNotFound) {
      created_framework.remove_use_case(@use_case.id)
    }
  end

  test "#remove_use_case raises with invalid UseCase" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_raises(ActiveRecord::RecordNotFound) {
      created_framework.remove_use_case(0)
    }
  end

  test "#destroy does not destroy the associated Language" do
    created_framework = Framework.create!(@valid_framework_params)
    language_id = @valid_framework_params[:language].id
    created_framework.destroy
    assert_nothing_raised {
      Language.find(language_id)
    }
  end

  test "#destroy removes all associated FrameworkUsesCases from the database" do
    created_framework = Framework.create!(@valid_framework_params)
    created_framework.add_use_case(name: @use_case.name)
    count = created_framework.use_cases.count
    assert_difference "FrameworkUseCase.count", -count do
      created_framework.destroy
    end
  end

  test "#destroy removes all associated ProjectFrameworks from the database" do
    created_framework = Framework.create!(@valid_framework_params)
    ProjectFramework.create!(project: @project, framework: created_framework)
    count = created_framework.projects.count
    assert_difference "ProjectFramework.count", -count do
      created_framework.destroy
    end
  end
end
