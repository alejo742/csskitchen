class DashboardController < ApplicationController
    before_action :require_authentication
    
    def index
        # user data
        @user = current_user
        @user_data = {
            first_initial: "#{@user.first_name[0]}",
            last_initial: "#{@user.last_name[0]}",
            score: "#{@user.score}"
        }

        # challenges data
        @all_challenges = Challenge.all
        @user_challenges = Challenge.where(user: @user)
        @others_challenges = @all_challenges - @user_challenges
    end
end