class CreateGhostCommutes < ActiveRecord::Migration
  def change
    create_table :ghost_commutes do |t|
      t.belongs_to :commute, index: true, foreign_key: true
      t.string :duration

      t.timestamps null: false
    end
  end
end
