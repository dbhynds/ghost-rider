class CreateStops < ActiveRecord::Migration
  def change
    create_table :stops do |t|
      t.integer :stop_id
      t.integer :stop_code
      t.string :stop_name
      t.string :stop_desc
      t.float :stop_lat
      t.float :stop_lon
      t.boolean :location_type
      t.boolean :parent_station
      t.boolean :wheelchair_boarding

      t.timestamps null: false
    end
  end
end
