class CreateDirections < ActiveRecord::Migration
  def change
    create_table :directions do |t|
      t.string :rt
      t.string :dir

      t.timestamps null: false
    end
  end
end
