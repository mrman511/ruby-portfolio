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

    @language = Language.create!(name: "Ruby")
    @framework = Framework.create!(name: "Ruby on Rails", language: @language)
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

  # #################
  # # ADD FRAMEWORK #
  # #################

  test "#add_framework creates a ProjectFramework with a valid Framework name" do
    created_project = Project.create!(@valid_project_params)
    assert_difference("ProjectFramework.count") {
      created_project.add_framework(@framework.id)
    }
  end

  test "#add_framework adds a Framework to framework.frameworks with a valid params that do not belong to a current Framework" do
    created_project = Project.create!(@valid_project_params)
    assert_difference("created_project.frameworks.count") {
      created_project.add_framework(@framework.id)
    }
  end

  test "#add_framework does not create a new Framework" do
    created_project = Project.create!(@valid_project_params)
    assert_difference("Framework.count", 0) {
      created_project.add_framework(@framework.id)
    }
  end

  # ####################
  # # REMOVE FRAMEWORK #
  # ####################

  test "#remove_framework Destroys a ProjectFramework in the data base with valid Framework that belongs with matching Project" do
    created_project = Project.create!(@valid_project_params)
    created_project.add_framework(@framework.id)
    assert_difference("ProjectFramework.count", -1) {
      created_project.remove_framework(@framework.id)
    }
  end

  test "#remove_framework removes a Framework from projects.frameworks with valid Framework that belongs with matching Project" do
    created_project = Project.create!(@valid_project_params)
    created_project.add_framework(@framework.id)
    assert_difference("created_project.frameworks.count", -1) {
      created_project.remove_framework(@framework.id)
    }
  end

  test "#remove_framework raises ActiveRecord::RecordNotFound with valid Framework that does not belong to the Project" do
    created_project = Project.create!(@valid_project_params)
    assert_raises(ActiveRecord::RecordNotFound) {
      created_project.remove_framework(@framework.id)
    }
  end

  test "#remove_framework raises ActiveRecord::RecordNotFound with invalid Framework" do
    created_project = Project.create!(@valid_project_params)
    assert_raises(ActiveRecord::RecordNotFound) {
      created_project.remove_framework(0)
    }
  end

  # ###########
  # # DESTROY #
  # ###########

  test "#destroy does not destroy the associated Framework" do
    created_project = Project.create!(@valid_project_params)
    created_project.add_framework(@framework.id)
    created_project.destroy
    assert_nothing_raised {
      Framework.find(@framework.id)
    }
  end

  test "#destroy removes all associated ProjectFrameworks from the database" do
    created_project = Project.create!(@valid_project_params)
    created_project.add_framework(@framework.id)
    count = created_project.frameworks.count
    assert_difference "ProjectFramework.count", -count do
      created_project.destroy
    end
  end
  
end
