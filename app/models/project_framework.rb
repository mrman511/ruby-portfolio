class ProjectFramework < ApplicationRecord
  belongs_to :project
  belongs_to :framework

  has_many :project_framework_use_cases, dependent: :destroy
  has_many :framework_use_cases, through: :project_framework_use_cases
  has_many :use_cases, through: :framework_use_cases

  validates :framework_id, uniqueness: { scope: :project_id, message: "The combination of framework and project must be unique" }

  def add_use_case(use_case_name)
    use_case = UseCase.find_or_create_by(name: use_case_name)
    framework_use_case = FrameworkUseCase.find_or_create_by(framework_id: self.framework.id, use_case: use_case)
    ProjectFrameworkUseCase.create!(project_framework: self, framework_use_case: framework_use_case)
  end

  def remove_use_case(use_case_id)
    use_case = UseCase.find(use_case_id)
    framework_use_case = FrameworkUseCase.where(framework: self, use_case: use_case).first
    project_framework_use_case = ProjectFrameworkUseCase.where(project_framework_id: self.id, framework_use_case_id: framework_use_case.id).first
    project_framework_use_case.destroy
  end
end
