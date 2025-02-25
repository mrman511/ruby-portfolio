class CreateUseCases < ActiveRecord::Migration[8.0]
  def change
    create_table :use_cases do |t|
      t.string :name

      t.timestamps
    end
  end
end
