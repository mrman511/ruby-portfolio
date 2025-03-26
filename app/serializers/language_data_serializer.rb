class LanguageDataSerializer < ActiveModel::Serializer
  attributes :id, :name, :frameworks, :icon_url

  def icon_url
    Rails.application.routes.url_helpers.rails_blob_url(object.icon, only_path: true) if object.icon.attached?
  end

  def frameworks
    object.frameworks.select(:id, :name).map do |framework|
      { id: framework.id, name: framework.name }
    end
  end
end
