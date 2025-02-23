require "test_helper"

class FrameworkTest < ActiveSupport::TestCase
  setup do
    @valid_framework_params = {
      name: "Ruby on Rails",
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }
  end

  test "#create adds a framework to the data base with valid params" do
    assert_difference("Framework.count") {
      Framework.create!(@valid_framework_params)
    }
  end

  test "#create creates a framework that can be retrieved from the database" do
    created_framework = Framework.create!(@valid_framework_params)
    assert_nothing_raised { Framework.find(created_framework.id) }
  end

  test "#name is a required attribute" do
    assert_raises(ActiveRecord::RecordInvalid) {
      Framework.create!(@valid_framework_params.except(:name))
    }
  end

  test "#name must be unique" do
    Framework.create!(@valid_framework_params)
    assert_raises(ActiveRecord::RecordInvalid) {
      Framework.create!(@valid_framework_params)
    }
  end

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
end
