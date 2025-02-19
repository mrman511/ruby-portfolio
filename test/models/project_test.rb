require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  setup do
    @valid_project_params = {
      title: "Pillpopper",
      description: "Lighthouse labs bootcamp final project",
      github_url: "https://github.com",
      live_url: "pillpopper.ca",
      role: "Co-creator",
      image: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }
  end

  test "#create adds a project to the data base with valid params" do
    assert_difference("Project.count") {
      Project.create!(@valid_project_params)
    }
  end

  test "#create creates a project that can be retrieved from the database" do
    created_project = Project.create!(@valid_project_params)
    assert_nothing_raised { Project.find(created_project.id) }
  end

  test "#title is a required attribute" do
    assert_raises(ActiveRecord::RecordInvalid) {
      Project.create!(@valid_project_params.except(:title))
    }
  end

  test "#description is a required attribute" do
    assert_raises(ActiveRecord::RecordInvalid) {
      Project.create!(@valid_project_params.except(:description))
    }
  end

  test "#github_url is a required attribute" do
    assert_raises(ActiveRecord::RecordInvalid) {
      Project.create!(@valid_project_params.except(:github_url))
    }
  end

  test "#role is a required attribute" do
    assert_raises(ActiveRecord::RecordInvalid) {
      Project.create!(@valid_project_params.except(:role))
    }
  end

  test "#image is a file attachment" do
    created_project = Project.create!(@valid_project_params)
    assert created_project.image.attached?
  end

  test "#image can be attached after project has been instantiated" do
    created_project = Project.create!(@valid_project_params.except(:image))
    created_project.image.attach(@valid_project_params[:image])
    assert created_project.image.attached?
  end

  test "#image can be removed" do
    created_project = Project.create!(@valid_project_params)
    created_project.image.purge
    assert_not created_project.image.attached?
  end
end
