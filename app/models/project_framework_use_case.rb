class ProjectFrameworkUseCase < ApplicationRecord
  belongs_to :project_framework
  belongs_to :framework_use_case

  validates :framework_use_case_id, uniqueness: { scope: :project_framework_id, message: "The combination of framework_use_case and project_framework must be unique" }
end
