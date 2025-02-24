require "test_helper"

class LanguageTest < ActiveSupport::TestCase
  setup do
    @valid_language_params = {
      name: "ruby",
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }
    @valid_framework_params = {
      name: "Ruby on Rails",
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }

    @preset_language = Language.create(name: "python")
    @preset_language_framework_1 = { name: "flask", icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg")) }
    @preset_language_framework_2 = { name: "django", icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg")) }
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

  test "#name is titleized when Language is created" do
    language = Language.create!(@valid_language_params)
    assert_not_equal @valid_language_params[:name], language.name
    assert_equal @valid_language_params[:name].titleize, language.name
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

  test "#create_framework adds a framework to the database" do
    assert_difference("Framework.count") {
      @preset_language.create_framework(@preset_language_framework_1)
    }
  end

  test "#create_framework adds a framework to the languages framworks" do
    assert_difference("@preset_language.frameworks.count") {
      @preset_language.create_framework(@preset_language_framework_1)
    }
  end

  test "#create_framework adds a framework to the language.framworks if language.frameworks count is  0" do
    assert_equal @preset_language.frameworks.count, 0
    assert_difference("@preset_language.frameworks.count") {
      @preset_language.create_framework(@preset_language_framework_1)
    }
  end

  test "#create_framework adds a framework to the language.framworks if language.frameworks count is greater than 0" do
    @preset_language.create_framework(@preset_language_framework_1)
    assert @preset_language.frameworks.count > 0
    assert_difference("@preset_language.frameworks.count") {
      @preset_language.create_framework(@preset_language_framework_2)
    }
  end

  test "#create_framework adds specified framework to the languages framworks" do
    new_framework = @preset_language.create_framework(@preset_language_framework_1)
    assert_includes @preset_language.frameworks, new_framework
  end

  test "#create_framework raises ArgumentError if no params provided" do
    assert_raises(ArgumentError) {
      @preset_language.create_framework()
    }
  end

  test "#delete_framework removes a framework from the database" do
    framework = @preset_language.create_framework(@preset_language_framework_1)
    assert_difference("Framework.count", -1) {
      @preset_language.delete_framework(framework.id)
    }
  end

  test "#delete_framework raises ActiveRecord::RecordInvalid if requested framework belongs to another language" do
    framework = @preset_language.create_framework(@preset_language_framework_1)
    created_language = Language.create!(@valid_language_params)
    other_framework = created_language.create_framework(@valid_framework_params)
    assert_raises(ActiveRecord::RecordInvalid) {
      @preset_language.delete_framework(other_framework.id)
    }
  end

  test "#delete_framework removes a framework from the languages frameworks" do
    framework = @preset_language.create_framework(@preset_language_framework_1)
    assert_difference("@preset_language.frameworks.count", -1) {
      @preset_language.delete_framework(framework.id)
    }
  end

  test "#delete_framework removes the specified framework from the languages frameworks" do
    new_framework_1 = @preset_language.create_framework(@preset_language_framework_1)
    new_framework_2 = @preset_language.create_framework(@preset_language_framework_2)
    new_framework_1_id = new_framework_1.id
    @preset_language.delete_framework(new_framework_1_id)
    @preset_language.frameworks.each do |framework|
      assert_not_equal framework.id, new_framework_1_id
    end
  end

  test "#destroy removes all associated frameworks from the database" do
    new_framework_1 = @preset_language.create_framework(@preset_language_framework_1)
    new_framework_2 = @preset_language.create_framework(@preset_language_framework_2)
    count = @preset_language.frameworks.count
    assert_difference("Framework.count", -count) {
      @preset_language.destroy
    }
  end
end
