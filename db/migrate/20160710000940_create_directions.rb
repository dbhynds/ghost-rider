class CreateDirections < ActiveRecord::Migration
  def change
    create_table :directions do |t|
      t.string :route
      t.string :direction

      t.timestamps null: false
    end
  end
end
