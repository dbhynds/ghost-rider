class CreatePatterns < ActiveRecord::Migration
  def change
    create_table :patterns do |t|
      t.integer :pid
      t.string :rt
      t.integer :pid
      t.integer :ln
      t.string :rtdir

      t.timestamps null: false
    end
  end
end
