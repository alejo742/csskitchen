class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :customer_name, null: false
      t.integer :timeline, default: 360, null: false
      t.string :message, default: "", null: false
      t.references :challenge, null: false, foreign_key: true

      t.timestamps
    end
  end
end
