require "test_helper"

class LanguageDataSerializerTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def setup
    @language = Language.create!(name: "Ruby")
    @language.icon.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg")),
      filename: "default-avatar.png",
      content_type: "image/jpg"
    )
    @framework = Framework.create!(name: "Rails", language: @language)

    @serializer = LanguageDataSerializer.new(@language)
    @data = @serializer.as_json
  end

  test "#as_json should include correct attributes" do
    assert_equal @language.id, @data[:id]
    assert_equal @language.name, @data[:name]
  end

  test "#as_json should include image_url if image is attached" do
    assert @data[:icon_url].include?("/rails/active_storage/blobs/")
  end

  test "#as_json should include frameworks" do
    assert_equal 1, @data[:frameworks].length
    assert_equal @framework.id, @data[:frameworks].first[:id]
  end
end
