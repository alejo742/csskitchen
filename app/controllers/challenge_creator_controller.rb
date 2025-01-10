class ChallengeCreatorController < ApplicationController
    before_action :require_authentication

    def index
        if not params[:random].present?
            @query = params[:query]
            @difficulty = params[:difficulty]
        else
            @query = "random" #implement random challenge
            @difficulty = "easy"
        end


    end


    private 

    def fetch_challenge 
        # fetch from open ai
    end

    def create_challenge
        challenge = Challenge.new(challenge_params)
        challenge.user = current_user
        challenge.save
    end

    def challenge_params
        params.require(:challenge).permit(:title, :description, :tags, :difficulty, :image_banner)
    end
end
