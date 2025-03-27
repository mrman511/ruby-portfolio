class ProjectFrameworkSerializer < ActiveModel::Serializer
  attributes(*Framework.attribute_names.map(&:to_sym), :use_cases)

  def object
    super.framework
  end

  def use_cases
    object.use_cases.uniq.map do |use_case|
      UseCaseSerializer.new(use_case).as_json
    end
  end
end
