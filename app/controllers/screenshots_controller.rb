class ScreenshotsController < ApplicationController
  layout 'splash'
  
  def index
    goto_more
  end
  
  def coursemap
    goto_more
  end
  
  def groups
    goto_more
  end
  
  def post
    goto_more
  end
  
  def round
    goto_more
  end
  
  def stats
    goto_more
  end
  
  def yourloopr
    goto_more
  end
  
  private
  def goto_more
    headers["Status"] = "301 Moved Permanently"
    redirect_to url_for(:controller => 'main', :action => 'more')
  end
  
end
