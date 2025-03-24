require "test_helper"

class ProjectFrameworkUseCaseTest < ActiveSupport::TestCase
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
    @framework_use_case = @framework.add_use_case(name: @use_case.name)
  end

  test "#create adds a ProjectFrameworkUseCase to the database" do
    assert_difference("ProjectFrameworkUseCase.count") do
      ProjectFrameworkUseCase.create!(framework_use_case: @framework_use_case, project_framework: @project_framework)
    end
  end

  test "#create raises ActiveRecord::RecordInvalid if combination of framework_use_case and project_framework is not unique" do
    ProjectFrameworkUseCase.create!(framework_use_case: @framework_use_case, project_framework: @project_framework)
    assert_raises(ActiveRecord::RecordInvalid) do
      ProjectFrameworkUseCase.create!(framework_use_case: @framework_use_case, project_framework: @project_framework)
    end
  end

  test "#create a ProjectFrameworkUseCase that can be retrieved from the database" do
    created_project_framework_use_case = ProjectFrameworkUseCase.create!(framework_use_case: @framework_use_case, project_framework: @project_framework)
    assert_nothing_raised {
      ProjectFrameworkUseCase.find(created_project_framework_use_case.id)
    }
  end

  test "#project_framework is a required param" do
    assert_raises (ActiveRecord::RecordInvalid) {
      ProjectFrameworkUseCase.create!(framework_use_case: @framework_use_case)
    }
  end

  test "#framework_use_case is a required param" do
    assert_raises (ActiveRecord::RecordInvalid) {
      ProjectFrameworkUseCase.create!(project_framework: @project_framework)
    }
  end

  test "#destroy removes a ProjectFrameworkUseCase from the database" do
    created_project_framework_use_case = ProjectFrameworkUseCase.create!(framework_use_case: @framework_use_case, project_framework: @project_framework)
    assert_difference("ProjectFrameworkUseCase.count", -1) {
      created_project_framework_use_case.destroy
    }
  end

  test "#destroy removes specific ProjectFrameworkUseCase from the database" do
    created_project_framework_use_case = ProjectFrameworkUseCase.create!(framework_use_case: @framework_use_case, project_framework: @project_framework)
    id = created_project_framework_use_case.id
    created_project_framework_use_case.destroy
    assert_raises(ActiveRecord::RecordNotFound) {
      ProjectFrameworkUseCase.find(id)
    }
  end

  test "#destroy does not remove a FrameworkUseCase from the database" do
    created_project_framework_use_case = ProjectFrameworkUseCase.create!(framework_use_case: @framework_use_case, project_framework: @project_framework)
    assert_difference("FrameworkUseCase.count", 0) {
      created_project_framework_use_case.destroy
    }
  end

  test "#destroy does not remove a ProjectFramework from the database" do
    created_project_framework_use_case = ProjectFrameworkUseCase.create!(framework_use_case: @framework_use_case, project_framework: @project_framework)
    assert_difference("ProjectFramework.count", 0) {
      created_project_framework_use_case.destroy
    }
  end
end
