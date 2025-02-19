require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      first_name: "Ring Finger",
      last_name: "Leonard",
      email: "leonhard@rosariasfingers.com",
      password: "R1nGf|ng3r",
      avatar: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
    }
    @invalid_email = "leonard_rosarias"
    # @avatar = File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg"))
  end

  test "#create! creates a user that can be fetched from the database" do
    created_user = User.create!(@valid_attributes)
    fetched_user = User.find(created_user.id)
    assert_equal @valid_attributes[:email], fetched_user.email
  end

    test "#create! adds default role :newuser to user.roles" do
      created_user = User.create!(@valid_attributes)
      assert_equal created_user.roles[0].name, "newuser"
    end

    test "#email is required to create a user" do
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes.except(:email)) }
    end

    test "#email can not be user to create more than one user" do
      first_user = User.create!(@valid_attributes)
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
    end

    test "#email needs to be proper format" do
      @valid_attributes[:email] = @invalid_email
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
    end

    test "#email needs to be converted to lowercase" do
      @valid_attributes[:email] = @valid_attributes[:email].upcase
      created_user = User.create!(@valid_attributes)
      assert_equal @valid_attributes[:email].downcase, created_user.email
    end

    test "#first_name is not a required param" do
      @valid_attributes.delete(:first_name)
      created_user = User.create!(@valid_attributes)
      fetched_user = User.find(created_user.id)
      assert_equal @valid_attributes[:email], fetched_user.email
    end

    test "#last_name is not a required param" do
      @valid_attributes.delete(:last_name)
      created_user = User.create!(@valid_attributes)
      fetched_user = User.find(created_user.id)
      assert_equal @valid_attributes[:email], fetched_user.email
    end

    test "#password is required to create a user" do
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes.except(:password)) }
    end

    test "#password cannot be less than 8 characters" do
      @valid_attributes[:password] = "Inv@l1d"
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
    end

    test "#password cannot be longer than 72 characters" do
      @valid_attributes[:password] = "F@1l" + ("a" * 69)
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
    end

    test "#password must have one lowercase letter" do
      @valid_attributes[:password] = @valid_attributes[:password].upcase
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
    end

    test "#password must have one uppercase letter" do
      @valid_attributes[:password] = @valid_attributes[:password].downcase
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
    end

    test "#password must have one number" do
      @valid_attributes[:password] = "nONumbeR$"
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
    end

    test "#password must have one symbol" do
      @valid_attributes[:password] = "n0Symb0ls"
      assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
    end

    test "#avatar is a file attachment" do
      created_user = User.create!(@valid_attributes)
      assert created_user.avatar.attached?
    end

    test "#avatar can be attached after user has been instantiated" do
      created_user = User.create!(@valid_attributes.except(:avatar))
      created_user.avatar.attach(@valid_attributes[:avatar])
      assert created_user.avatar.attached?
    end

  test "#avatar can be removed" do
    created_user = User.create!(@valid_attributes)
    created_user.avatar.purge
    assert_not created_user.avatar.attached?
  end
end
