class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string :rt
      t.integer :vid
      t.string :tmstmp
      t.float :lat
      t.float :lon
      t.integer :hdg
      t.integer :pid
      t.integer :pdist
      t.string :rt
      t.string :des
      t.boolean :dly

      t.timestamps null: false
    end
  end
end
