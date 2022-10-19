class PagesController < ApplicationController
  def home
    if current_user 
      if !current_user.ruolo
        #redirect_to '/profile/nameandrole' 
        #dovrò invece metterci la pagina di modifica ruolo
      end
    end
  end
end
