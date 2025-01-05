class Challenge < ApplicationRecord
    belongs_to :user

    def image_banner_url
        image_banner.present? ? image_banner : ActionController::Base.helpers.asset_path('challenges/default-food-image.jpg')
    end
end
