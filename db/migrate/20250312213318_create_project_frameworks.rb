class CreateProjectFrameworks < ActiveRecord::Migration[8.0]
  def change
    create_table :project_frameworks do |t|
      t.references :project, null: false, foreign_key: true
      t.references :framework, null: false, foreign_key: true

      t.timestamps
    end
  end
end
