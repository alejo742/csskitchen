class ChallengeCreatorController < ApplicationController
    before_action :require_authentication

    def index
        if params[:random].present? || params[:query].strip == ""
            params[:query] = "random" # implement random challenge
            params[:difficulty] = "easy"
        end

        @query = params[:query]
        @difficulty = params[:difficulty]
    end
end
