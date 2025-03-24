class Framework < ApplicationRecord
  belongs_to :language
  has_many :framework_use_cases, dependent: :destroy
  has_many :use_cases, through: :framework_use_cases

  has_many :project_frameworks, dependent: :destroy
  has_many :projects, through: :project_frameworks

  has_one_attached :icon

  before_validation :titleize_name

  validates :name, presence: true, uniqueness: true

  def add_use_case(params)
    params[:name].titleize if params[:name].present?
    use_case = UseCase.find_or_create_by(params)
    FrameworkUseCase.create!(use_case: use_case, framework: self)
  end

  def remove_use_case(use_case_id)
    use_case = UseCase.find(use_case_id)
    framework_use_case = FrameworkUseCase.where(use_case: use_case, framework_id: self).first
    if framework_use_case.present?
      framework_use_case.destroy
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def titleize_name
    self.name = name.titleize if name.present?
  end
end
