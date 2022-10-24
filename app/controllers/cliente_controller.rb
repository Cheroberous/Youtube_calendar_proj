
class ClienteController < ApplicationController

    before_action:require_user_logged_in!

    def search
        @users = User.all
    end

    def function
    end

end