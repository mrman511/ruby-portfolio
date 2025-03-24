require "test_helper"

class FrameworkUseCaseTest < ActiveSupport::TestCase
  setup do
    @language = Language.create!(name: "Ruby")
    @framework = Framework.create!(name: "Ruby on Rails", language: @language)
    @use_case = UseCase.create!(name: "Server")

    @project = Project.create!(
      title: "Portfolio",
      description: "A website to display all of my previous projects and achievement's",
      github_url: "https://github.com/mrman511",
      role: "Creator"
    )
    @project_framework = @project.add_framework(@framework.id)
  end

  test "#create adds a FrameWorkUseCase to the database" do
    assert_difference("FrameworkUseCase.count") do
      FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    end
  end

  test "#create raises ActiveRecord::RecordInvalid if combination of framework and use_case is not unique" do
    FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    assert_raises(ActiveRecord::RecordInvalid) do
      FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    end
  end

  test "#create a FrameworkUseCase that can be retrieved from the database" do
    framework_use_case = FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    assert_nothing_raised {
      FrameworkUseCase.find(framework_use_case.id)
    }
  end

  test "#use_case is a required param" do
    assert_raises (ActiveRecord::RecordInvalid) {
      FrameworkUseCase.create!(framework: @framework)
    }
  end

  test "#framework is a required param" do
    assert_raises (ActiveRecord::RecordInvalid) {
      FrameworkUseCase.create!(use_case: @use_case)
    }
  end

  test "#destroy removes a FrameworkUseCase from the database" do
    framework_use_case = FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    assert_difference("FrameworkUseCase.count", -1) {
      framework_use_case.destroy
    }
  end

  test "#destroy removes specific FrameworkUseCase from the database" do
    framework_use_case = FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    id = framework_use_case.id
    framework_use_case.destroy
    assert_raises(ActiveRecord::RecordNotFound) {
      FrameworkUseCase.find(id)
    }
  end

  test "#destroy does not remove a Framework from the database" do
    framework_use_case = FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    assert_difference("Framework.count", 0) {
      framework_use_case.destroy
    }
  end

  test "#destroy does not remove a UseCase from the database" do
    framework_use_case = FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    assert_difference("UseCase.count", 0) {
      framework_use_case.destroy
    }
  end

  test "#destroy removes a ProjectFrameworkUseCase from the database" do
    framework_use_case = FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    project_framework_use_case = @project_framework.add_use_case(@use_case.name)
    assert_difference("ProjectFrameworkUseCase.count", -1) {
      framework_use_case.destroy
    }
  end

  test "#destroy removes specified ProjectFrameworkUseCase from the database" do
    framework_use_case = FrameworkUseCase.create!(framework: @framework, use_case: @use_case)
    project_framework_use_case = @project_framework.add_use_case(@use_case.name)
    id = project_framework_use_case.id
    framework_use_case.destroy
    assert_raises(ActiveRecord::RecordNotFound) {
      ProjectFrameworkUseCase.find(id)
    }
  end
end
