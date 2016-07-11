class CreateCommutes < ActiveRecord::Migration
  def change
    create_table :commutes do |t|
      t.belongs_to :user, index: true
      t.string :origin
      t.string :dest
      t.string :departure_time
      t.float :origin_lat
      t.float :origin_long
      t.string :dest_lat
      t.string :dest_long

      t.timestamps null: false
    end
  end
end
