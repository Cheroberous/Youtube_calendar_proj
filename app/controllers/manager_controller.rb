
class ManagerController < ApplicationController

    before_action:require_user_logged_in!

    def index
    end

    def affiliazioni
        @affiliazioni=Affiliation.all
    end
end