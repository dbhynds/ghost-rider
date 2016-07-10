class CreateBusdirections < ActiveRecord::Migration
  def change
    create_table :busdirections do |t|
      t.string :dir, unique: true

      t.timestamps null: false
    end
  end
end
