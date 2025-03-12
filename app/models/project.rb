class Project < ApplicationRecord
  has_one_attached :image

  has_many :project_frameworks, dependent: :delete_all
  has_many :frameworks, through: :project_frameworks

  validates :title, presence: true
  validates :description, presence: true
  validates :github_url, presence: true
  validates :role, presence: true

  private

  def add_framework(framework_id)
    framework = Framework.find(framework_id)
    ProjectFramework.create!(project: self, framework: framework)
  end

  def remove_framework(framework_id)
    project_framework = ProjectFramework.where(project_id: self.id, framework_id: framework_id)
    if project_framework.present?
      project_framework.destroy
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
