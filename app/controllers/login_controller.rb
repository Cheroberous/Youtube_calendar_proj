class LoginController < ApplicationController
  before_action :authenticate_user!

  def base
  end
end
