class CreateActiveSteps < ActiveRecord::Migration
  def change
    create_table :active_steps do |t|
      t.belongs_to :ghost_step, index: true, foreign_key: true
      t.string :start_time
      t.boolean :arriving_at_origin, :default => false
      t.boolean :arrived_at_origin, :default => false
      t.boolean :arriving_at_dest, :default => false
      t.boolean :arrived_at_dest, :default => false
      t.string :request
      t.string :arriving_vehicles
      t.string :watched_vehicles

      t.timestamps null: false
    end
  end
end
