class DashboardController < ApplicationController
    before_action :require_authentication
    
    def index
        @user = current_user
        @user_name_data = {
            first_initial: "#{@user.first_name[0]}",
            last_initial: "#{@user.last_name[0]}"
        }
    end
end