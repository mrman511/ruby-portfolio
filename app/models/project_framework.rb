class ProjectFramework < ApplicationRecord
  belongs_to :project
  belongs_to :framework

  validates :framework_id, uniqueness: { scope: :project_id, message: "The combination of framework and project must be unique" }
end
