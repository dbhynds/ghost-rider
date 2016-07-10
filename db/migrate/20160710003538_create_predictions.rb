class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.integer :stpid
      t.string :rt
      t.integer :vid
      t.string :tmstmp
      t.string :typ
      t.integer :stpid
      t.string :stpnm
      t.integer :vid
      t.integer :dstp
      t.string :rtdir
      t.string :des
      t.string :prdtm
      t.boolean :delay

      t.timestamps null: false
    end
  end
end
