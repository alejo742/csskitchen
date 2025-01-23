module ApplicationHelper
    def challenge_image(challenge)
        challenge.image_banner.presence || challenge.sample_image
    end
end
