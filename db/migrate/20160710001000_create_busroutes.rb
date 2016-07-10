class CreateBusroutes < ActiveRecord::Migration
  def change
    create_table :busroutes do |t|
      t.belongs_to :busline, index: true
      t.belongs_to :busdirection, index: true

      t.timestamps null: false
    end
  end
end
