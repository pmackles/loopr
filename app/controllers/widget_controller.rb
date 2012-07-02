class WidgetController < ApplicationController
  layout "standard"
  
  before_filter :login_required, :only => 'preview'
  
  def preview
    @user = current_user
    params[:id] = 'stats' unless params[:id]    
  end
  
  def stats
    @user = User.find_by_id_or_username(params)
    @stats = @user.stats || UserLast20StatSummary.new
    
    render :layout => false
  end
end
