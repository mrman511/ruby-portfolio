require "test_helper"

class ProjectSerializerTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def setup
    @project = Project.create!(
      title: "Test Project",
      description: "A description for the test project.",
      github_url: "https://github.com/mrman511",
      live_url: "https://paulbodner.com",
      role: "Developer"
    )
    
    @project.image.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg")),
      filename: "default-avatar.png",
      content_type: "image/jpg"
    )

    @language = Language.create!(name: "Ruby")
    @framework = Framework.create!(name: "Rails", language: @language)
    @project.add_framework(@framework.id)

    @serializer = ProjectSerializer.new(@project)
    @data = @serializer.as_json
  end

  test "#as_json should include correct attributes" do
    assert_equal @project.id, @data[:id]
    assert_equal @project.title, @data[:title]
    assert_equal @project.description, @data[:description]
    assert_equal @project.github_url, @data[:github_url]
    assert_equal @project.role, @data[:role]
    assert_equal @project.live_url, @data[:live_url]
  end

  test "#as_json should include image_url if image is attached" do
    assert @data[:image_url].include?("/rails/active_storage/blobs/")
  end

  test "#as_json should include frameworks" do
    assert_equal 1, @data[:frameworks].length
    assert_equal "Rails", @data[:frameworks].first["name"]
  end

  test "#as_json should include languages" do
    assert_equal 1, @data[:languages].length
    assert_equal "Ruby", @data[:languages].first["name"]
  end
end
