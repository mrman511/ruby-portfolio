require "test_helper"

class UseCaseTest < ActiveSupport::TestCase
  setup do
    @use_case = UseCase.create!(name: "Back End")
    @serializer = UseCaseSerializer.new(@use_case)
    @data = @serializer.as_json
  end

  test "#as_json should include correct attributes" do
    assert_equal @use_case.name, @data[:name]
  end
end
