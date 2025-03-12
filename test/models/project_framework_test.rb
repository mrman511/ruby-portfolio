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
    framework_project = ProjectFramework.create!(framework: @framework, project: @project)
    assert_nothing_raised {
      ProjectFramework.find(framework_project.id)
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

  test "#destroy removes a ProjectFramework from the database" do
    framework_project = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("ProjectFramework.count", -1) {
      framework_project.destroy
    }
  end

  test "#destroy removes specific ProjectFramework from the database" do
    framework_project = ProjectFramework.create!(framework: @framework, project: @project)
    id = framework_project.id
    framework_project.destroy
    assert_raises(ActiveRecord::RecordNotFound) {
      ProjectFramework.find(id)
    }
  end

  test "#destroy does not remove a Framework from the database" do
    framework_project = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("Framework.count", 0) {
      framework_project.destroy
    }
  end

  test "#destroy does not remove a Project from the database" do
    framework_project = ProjectFramework.create!(framework: @framework, project: @project)
    assert_difference("Project.count", 0) {
      framework_project.destroy
    }
  end
end
