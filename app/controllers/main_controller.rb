class MainController < ApplicationController
  layout 'standard'
  
  def screenshots
    headers["Status"] = "301 Moved Permanently"
    redirect_to url_for(:action => 'more')
  end
  
  def index
    return index_logged_in if logged_in?

    @right_now_rounds = Round.list(:limit => 16)
    @gstats = StatSummary.find_by_entity_id_and_name(0, "global")
    
    render :layout => 'splash', :action => 'splash_index2'
  end
  
  private
  
  def index_logged_in
    @user = current_user
    @courses = @user.saved_courses.collect { |sc| sc.course }
    @rounds = Round.list
    @groups = Group.find_by_sql("select g.*, max(r.created_on) as last_updated from groups g, memberships m, rounds r where g.id=m.group_id and m.user_id=r.user_id and g.id in (select group_id from memberships ms where ms.user_id=#{@user.id}) group by 1,2")
    render :action => 'index2'
  end
  
end
