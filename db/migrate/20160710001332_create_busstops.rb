class CreateBusstops < ActiveRecord::Migration
  def change
    create_table :busstops do |t|
      t.integer :stpid, index: true
      t.string :stpnm, index: true
      t.float :lat, index: true
      t.float :lon, index: true

      t.timestamps null: false
    end

    create_table :busroutes_busstops, id: false do |t|
      t.belongs_to :busroute, index: true
      t.belongs_to :busstop, index: true
    end
  end
end
