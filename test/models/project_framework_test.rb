require "test_helper"

class ProjectFrameworkTest < ActiveSupport::TestCase
  setup do
    @language = Language.create!(name: "Ruby")
    @framework = Framework.create!(name: "Ruby on Rails", language: @language)
    @project = Project.create!(
      title: "Portfolio",
      description: "A website to display all of my previous projects and achievement's",
      github_url: "https://github.com/mrman511",
      role: "Creator"
    )
    @use_case = UseCase.create!({ name: "Server" })
    @new_use_case_name = "api"
  end

  test "#create adds a ProjectFramework to the database" do
    assert_difference("ProjectFramework.count") do
      ProjectFramework.create!(framework: @framework, project: @project)
    end
  end

  test "#create raises ActiveRecord::RecordInvalid if combination of framework and project is not unique" do
    ProjectFramework.create!(framework: @framework, project: @project)
    assert_raises(ActiveRecord::RecordInvalid) do
      ProjectFramework.create!(framework: @framework, project: @project)
    end
  end

  test "#create a ProjectFramework that can be retrieved from the database" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    assert_nothing_raised {
      ProjectFramework.find(project_framework.id)
    }
  end

  test "#project is a required param" do
    assert_raises (ActiveRecord::RecordInvalid) {
      ProjectFramework.create!(framework: @framework)
    }
  end

  test "#framework is a required param" do
    assert_raises (ActiveRecord::RecordInvalid) {
      ProjectFramework.create!(project: @project)
    }
  end

  # ################
  # # ADD USE CASE #
  # ################

  test "#add_use_case adds a new ProjectFrameworkUseCase to the database with valid use_case" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("ProjectFrameworkUseCase.count") {
      project_framework.add_use_case(@use_case.name)
    }
  end

  test "#add_use_case adds a new use_case to the project_framework" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("project_framework.use_cases.count") {
      project_framework.add_use_case(@use_case.name)
    }
  end

  test "#add_use_case adds a new UseCase to the database if not given a current UseCase" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("UseCase.count") {
      project_framework.add_use_case(@new_use_case_name)
    }
  end

  test "#add_use_case adds a new FrameworkUseCase to the database if not given a current UseCase" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("FrameworkUseCase.count") {
      project_framework.add_use_case(@new_use_case_name)
    }
  end

  # ###################
  # # REMOVE USE CASE #
  # ###################

  test "#remove_use_case removes a ProjectFrameworkUseCase from the database with valid UseCase id" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    project_framework.add_use_case(@use_case.name)
    assert_difference("ProjectFrameworkUseCase.count", -1) {
      project_framework.remove_use_case(@use_case.id)
    }
  end

  test "#remove_use_case removes a ProjectFrameworkUseCase from project_frameworks.use_cases UseCase id" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    project_framework.add_use_case(@use_case.name)
    assert_difference("project_framework.use_cases.count", -1) {
      project_framework.remove_use_case(@use_case.id)
    }
  end

  test "#remove_use_case raises NoMethodError with UseCase id not in project_framework.use_cases" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    project_framework.add_use_case(@new_use_case_name)
    assert_raises(NoMethodError) {
      project_framework.remove_use_case(@use_case.id)
    }
  end

  # ###########
  # # DESTROY #
  # ###########

  test "#destroy removes a ProjectFramework from the database" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("ProjectFramework.count", -1) {
      project_framework.destroy
    }
  end

  test "#destroy removes specific ProjectFramework from the database" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    id = project_framework.id
    project_framework.destroy
    assert_raises(ActiveRecord::RecordNotFound) {
      ProjectFramework.find(id)
    }
  end

  test "#destroy does not remove a Framework from the database" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("Framework.count", 0) {
      project_framework.destroy
    }
  end

  test "#destroy does not remove a Project from the database" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("Project.count", 0) {
      project_framework.destroy
    }
  end

  test "#destroy removes all related ProjectFrameworkUses from the database" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    project_framework.add_use_case(@use_case.name)
    count = project_framework.use_cases.count
    assert_difference("ProjectFrameworkUseCase.count", -count) {
      project_framework.destroy
    }
  end

  test "#destroy does not remove FrameworkUses from the database" do
    project_framework = ProjectFramework.create!(framework: @framework, project: @project)
    project_framework.add_use_case(@use_case.name)
    count = project_framework.use_cases.count
    assert_difference("FrameworkUseCase.count", 0) {
      project_framework.destroy
    }
  end
end
