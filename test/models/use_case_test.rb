require "test_helper"

class UseCaseTest < ActiveSupport::TestCase
  setup do
    @language = Language.create!({ name: "Ruby" })
    @framework = Framework.create!(
      name: "ruby on rails",
      language: @language,
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    )
    @valid_use_case_params = {
      name: "server",
      icon: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }
  end

  test "#create adds a use_case to the data base with valid params" do
    assert_difference("UseCase.count") {
      UseCase.create!(@valid_use_case_params)
    }
  end

  test "#create creates a use_case that can be retrieved from the database" do
    created_use_case = UseCase.create!(@valid_use_case_params)
    assert_nothing_raised { UseCase.find(created_use_case.id) }
  end

  test "#name is a required attribute" do
    assert_raises(ActiveRecord::RecordInvalid) {
      UseCase.create!(@valid_use_case_params.except(:name))
    }
  end

  test "#name is titleized when UseCase is created" do
    use_case = UseCase.create!(@valid_use_case_params)
    assert_not_equal @valid_use_case_params[:name], use_case.name
    assert_equal @valid_use_case_params[:name].titleize, use_case.name
  end

  test "#name must be unique" do
    UseCase.create!(@valid_use_case_params)
    assert_raises(ActiveRecord::RecordInvalid) {
      UseCase.create!(@valid_use_case_params)
    }
  end

  test "#icon is a file attachment" do
    created_use_case = UseCase.create!(@valid_use_case_params)
    assert created_use_case.icon.attached?
  end

  test "#icon can be attached after use_case has been instantiated" do
    created_use_case = UseCase.create!(@valid_use_case_params.except(:icon))
    created_use_case.icon.attach(@valid_use_case_params[:icon])
    assert created_use_case.icon.attached?
  end

  test "#icon can be removed" do
    created_use_case = UseCase.create!(@valid_use_case_params)
    created_use_case.icon.purge
    assert_not created_use_case.icon.attached?
  end

  test "#destroy removes associated FrameworkUsesCases from the database" do
    created_use_case = UseCase.create!(@valid_use_case_params)
    @framework.add_use_case(name: created_use_case.name)
    count = created_use_case.frameworks.count
    assert_difference "FrameworkUseCase.count", -count do
      created_use_case.destroy
    end
  end
end
