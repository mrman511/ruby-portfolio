class CreateProjectFrameworkUseCases < ActiveRecord::Migration[8.0]
  def change
    create_table :project_framework_use_cases do |t|
      t.references :project_framework, foreign_key: true
      t.references :framework_use_case, foreign_key: true

      t.timestamps
    end
  end
end
