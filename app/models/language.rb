class Language < ApplicationRecord
  has_many :frameworks, dependent: :delete_all
  has_one_attached :icon

  before_validation :titleize_name

  validates :name, presence: true, uniqueness: true

  def create_framework(framework_params)
    framework_params["language"] = self
    @new_framework = Framework.create!(framework_params)
    @new_framework
  end

  def delete_framework(framework_id)
    framework = Framework.find(framework_id)
    if framework.language == self
      framework.destroy
    else
      raise ActiveRecord::RecordInvalid.new, "Framework does not belong to this language"
    end
  end

  private

  def titleize_name
    self.name = name.titleize if name.present?
  end
end
