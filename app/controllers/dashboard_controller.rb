class DashboardController < ApplicationController
    before_action :require_authentication
  
    def index
        @user = current_user
    end
end