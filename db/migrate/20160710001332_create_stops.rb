class CreateStops < ActiveRecord::Migration
  def change
    create_table :stops do |t|
      t.string :rt
      t.string :dir
      t.integer :stpid
      t.string :stpnm
      t.float :lat
      t.float :lon

      t.timestamps null: false
    end
  end
end
