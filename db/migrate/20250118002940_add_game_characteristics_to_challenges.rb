class AddGameCharacteristicsToChallenges < ActiveRecord::Migration[7.1]
  def change
    add_column :challenges, :sample_image, :string, default: ActionController::Base.helpers.image_path('challenges/chicken-alfredo.jpeg'), null: false
    add_column :challenges, :order_ids, :integer, array: true, default: [], null: false
    add_column :challenges, :color_codes, :string, default: "/* red */\nrgba(255, 0, 0, 1)\n/* green */\nrgba(0, 255, 0, 1)\n/* blue */\nrgba(0, 0, 255, 1)", null: false
  end
end
