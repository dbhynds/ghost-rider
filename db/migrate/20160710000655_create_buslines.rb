class CreateBuslines < ActiveRecord::Migration
  def change
    create_table :buslines do |t|
      t.string :rt, index: true
      t.string :rtnm

      t.timestamps null: false
    end
  end
end
