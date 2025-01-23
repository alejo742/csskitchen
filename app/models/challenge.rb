require 'open-uri'

class Challenge < ApplicationRecord
  belongs_to :user
  has_many :orders
  has_one_attached :image_banner
  after_create :download_and_attach_image_banner

  validates :title, presence: true
  validates :description, presence: true
  validates :tags, presence: true
  validates :sample_image, presence: true
  validates :color_codes, presence: true
  validates :difficulty, presence: true

  def image_banner_url
    image_banner.attached? ? image_banner : ActionController::Base.helpers.asset_path('challenges/default-food-image.jpg')
  end

  private

  def download_and_attach_image_banner # scrape generated image and attach to challenge
    return unless sample_image.present?

    uri = URI.parse(sample_image)
    image = uri.open
    image_name = File.basename(sample_image)
    self.image_banner.attach(io: image, filename: image_name, content_type: 'image/png')
  rescue => e
    Rails.logger.error "Failed to attach image for challenge ID: #{id}, error: #{e.message}"
  end
end
