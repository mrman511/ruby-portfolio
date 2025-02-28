class Framework < ApplicationRecord
  belongs_to :language
  has_many :framework_use_cases, dependent: :delete_all
  has_many :use_cases, through: :framework_use_cases

  has_one_attached :icon

  before_validation :titleize_name

  validates :name, presence: true, uniqueness: true

  def add_use_case(use_case_id)
    use_case = UseCase.find(use_case_id)
    FrameworkUseCase.create!(use_case: use_case, framework: self)
  end

  private

  def titleize_name
    self.name = name.titleize if name.present?
  end
end
