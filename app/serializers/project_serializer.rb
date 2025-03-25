class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :github_url, :role, :image_url

  has_many :frameworks
  has_many :languages

  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(object.image, only_path: true) if object.image.attached?
  end
end
