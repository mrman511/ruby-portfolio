class User < ApplicationRecord
  rolify

  after_create :assign_default_role

  has_secure_password

  has_one_attached :avatar

  before_save :downcase_email

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  validates :password, length: { minimum: 8, maximum: 72 }
  validate :password_requirements_are_met

  private

  def assign_default_role
    self.add_role(:newuser) if self.roles.blank?
  end

  def downcase_email
    self.email = email.downcase
  end

  def password_requirements_are_met
    rules = {
      " must contain at least one lowercase letter"  => /[a-z]+/,
      " must contain at least one uppercase letter"  => /[A-Z]+/,
      " must contain at least one digit"             => /\d+/,
      " must contain at least one special character" => /[^A-Za-z0-9]+/
    }

    rules.each do |message, regex|
      errors.add(:password, message) unless password.match(regex)
    end
  end
end
