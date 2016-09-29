class CreateGhostSteps < ActiveRecord::Migration
  def change
    create_table :ghost_steps do |t|
      t.belongs_to :ghost_commute, index: true, foreign_key: true
      t.string :mode
      t.string :step_type
      t.string :line
      t.string :origin
      t.float :origin_lat
      t.float :origin_long
      t.string :dest
      t.float :dest_lat
      t.float :dest_long
      t.string :heading
      t.string :duration
      t.boolean :completed, :default => false

      t.timestamps null: false
    end
  end
end
