class UseCase < ApplicationRecord
  has_many :framework_use_cases, dependent: :delete_all
  has_many :frameworks, through: :framework_use_cases

  has_one_attached :icon

  before_validation :titleize_name

  validates :name, presence: true, uniqueness: true

  private

  def titleize_name
    self.name = name.titleize if name.present?
  end
end
