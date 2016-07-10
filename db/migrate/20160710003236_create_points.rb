class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.integer :ptrid
      t.integer :seq
      t.string :typ
      t.integer :stpid
      t.string :sptnm
      t.float :pdist
      t.float :lat
      t.float :lon

      t.timestamps null: false
    end
  end
end
