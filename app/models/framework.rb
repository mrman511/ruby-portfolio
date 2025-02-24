class Framework < ApplicationRecord
  belongs_to :language

  has_one_attached :icon

  before_validation :titleize_name

  validates :name, presence: true, uniqueness: true

  private

  def titleize_name
    self.name = name.titleize if name.present?
  end
end
