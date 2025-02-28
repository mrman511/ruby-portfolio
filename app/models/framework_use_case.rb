class FrameworkUseCase < ApplicationRecord
  belongs_to :framework
  belongs_to :use_case

  validates :framework_id, uniqueness: { scope: :use_case_id, message: "The combination of framework and use case must be unique" }
end
