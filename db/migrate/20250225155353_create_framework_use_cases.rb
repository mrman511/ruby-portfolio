class CreateFrameworkUseCases < ActiveRecord::Migration[8.0]
  def change
    create_table :framework_use_cases do |t|
      t.references :framework, foreign_key: true
      t.references :use_case, foreign_key: true
      t.timestamps
    end
  end
end
