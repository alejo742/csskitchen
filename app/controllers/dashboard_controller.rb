class DashboardController < ApplicationController
    before_action :require_authentication
    
    def index
        # user data
        @user = current_user
        @user_name_data = {
            first_initial: "#{@user.first_name[0]}",
            last_initial: "#{@user.last_name[0]}"
        }

        # challenges data
        @displayed_challenges = Challenge.all
    end
end