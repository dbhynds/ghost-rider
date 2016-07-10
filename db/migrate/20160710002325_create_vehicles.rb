class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.belongs_to :route, index: true
      t.integer :vid, index: true
      t.string :tmstmp
      t.float :lat, index: true
      t.float :lon, index: true
      t.integer :hdg
      t.integer :pid
      t.integer :pdist
      t.string :des
      t.boolean :dly

      t.timestamps null: false
    end
  end
end
