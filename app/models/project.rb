class Project < ApplicationRecord
  has_one_attached :image

  validates :title, presence: true
  validates :description, presence: true
  validates :github_url, presence: true
  validates :role, presence: true
end
