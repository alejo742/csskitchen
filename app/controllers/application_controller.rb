class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    helper_method :current_user

    def require_authentication
        redirect_to root_path, alert: 'Requires authentication' unless user_signed_in?
    end

    def current_user
        if session[:user_id]
            unless @current_user
                @current_user = User.find(session[:user_id])
            end
        end
        return @current_user
    end

    def user_signed_in?
        # converts current_user to a boolean by negating the negation
        !!current_user
    end
end
