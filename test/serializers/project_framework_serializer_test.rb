require "test_helper"

class ProjectFrameworkSerializerTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def setup
    @project = Project.create!(
      title: "Test Project",
      description: "A description for the test project.",
      github_url: "https://github.com/example/test-project",
      role: "Developer"
    )
    @project.image.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "default-avatar.jpg")),
      filename: "default-avatar.png",
      content_type: "image/jpg"
    )

    @language = Language.create!(name: "Ruby")
    @framework = Framework.create!(name: "Rails", language: @language)
    @use_case = UseCase.create!(name: "UI/UX")
    @project_framework = @project.add_framework(@framework.id)
    @project_framework.add_use_case(@use_case.name)

    @serializer = ProjectFrameworkSerializer.new(@project_framework)
    @data = @serializer.as_json
  end

  test "#as_json should include correct attributes" do
    assert_equal @framework.id, @data[:id]
    assert_equal @framework.name, @data[:name]
    assert_equal @framework.language_id, @data[:language_id]
  end

  # test "#as_json should include image_url if image is attached" do
  #   assert @data[:image_url].include?("/rails/active_storage/blobs/")
  # end

  # test "#as_json should include frameworks" do
  #   assert_equal 1, @data[:frameworks].length
  #   assert_equal "Rails", @data[:frameworks].first["name"]
  # end

  # test "#as_json should include languages" do
  #   assert_equal 1, @data[:languages].length
  #   assert_equal "Ruby", @data[:languages].first["name"]
  # end
end
