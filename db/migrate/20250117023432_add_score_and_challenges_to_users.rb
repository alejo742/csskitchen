class AddScoreAndChallengesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :score, :integer, default: 0, null: false
    add_column :users, :challenge_ids, :string, array: true, default: [], null: false
  end
end

