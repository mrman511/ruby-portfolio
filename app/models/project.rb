class Project < ApplicationRecord
  has_one_attached :image

  has_many :project_frameworks, dependent: :delete_all
  has_many :frameworks, through: :project_frameworks
  has_many :languages, -> { distinct }, through: :frameworks

  validates :title, presence: true
  validates :description, presence: true
  validates :github_url, presence: true
  validates :role, presence: true

  def add_framework(framework_id)
    framework = Framework.find(framework_id)
    ProjectFramework.create!(project: self, framework: framework)
  end

  def remove_framework(framework_id)
    project_framework = ProjectFramework.where(project_id: self.id, framework_id: framework_id).first
    if project_framework.present?
      project_framework.destroy
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
