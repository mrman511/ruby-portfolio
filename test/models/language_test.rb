require "test_helper"

class LanguageTest < ActiveSupport::TestCase
  setup do
    @valid_language_params = {
      name: "Ruby",
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }
  end

  test "#create adds a language to the data base with valid params" do
    assert_difference("Language.count") {
      Language.create!(@valid_language_params)
    }
  end

  test "#create creates a language that can be retrieved from the database" do
    created_language = Language.create!(@valid_language_params)
    assert_nothing_raised { Language.find(created_language.id) }
  end

  test "#name is a required attribute" do
    assert_raises(ActiveRecord::RecordInvalid) {
      Language.create!(@valid_language_params.except(:name))
    }
  end

  test "#name must be unique" do
    Language.create!(@valid_language_params)
    assert_raises(ActiveRecord::RecordInvalid) {
      Language.create!(@valid_language_params)
    }
  end

  test "#icon is a file attachment" do
    created_language = Language.create!(@valid_language_params)
    assert created_language.icon.attached?
  end

  test "#icon can be attached after language has been instantiated" do
    created_language = Language.create!(@valid_language_params.except(:icon))
    created_language.icon.attach(@valid_language_params[:icon])
    assert created_language.icon.attached?
  end

  test "#icon can be removed" do
    created_language = Language.create!(@valid_language_params)
    created_language.icon.purge
    assert_not created_language.icon.attached?
  end
end
