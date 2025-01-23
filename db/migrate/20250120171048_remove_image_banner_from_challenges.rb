class RemoveImageBannerFromChallenges < ActiveRecord::Migration[7.1]
  def change
    remove_column :challenges, :image_banner, :string
  end
end
