
class StatsController < ApplicationController

  layout :userlayout

  def show
    headers["Status"] = "301 Moved Permanently"
    redirect_to(stats_url(:id => params[:id]))
  end
    
end
