class InviteController < ApplicationController
  
  layout "standard"

  def accept

    begin
      token = SecureToken.parse(Invite::TOKEN_TYPE, params[:xyz])
    rescue
      render :action => 'accept_fail'
      return
    end
    
    @invite = Invite.find(token.id)
    
    if guest_user?
      render :action => 'accept_login'
      store_location
      return
    end
    
    if @invite.accept current_user
      flash[:notice] = @invite.success_msg
      redirect_to @invite.success_url
      return
    end

  end
  
end
