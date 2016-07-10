class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :rt
      t.string :rtnm

      t.timestamps null: false
    end
  end
end
