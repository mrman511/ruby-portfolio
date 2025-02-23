class Language < ApplicationRecord
  has_one_attached :icon

  validates :name, presence: true, uniqueness: true
end
