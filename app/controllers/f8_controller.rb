class F8Controller < ApplicationController
  
  before_filter :login_required, :only => [:index, :invite, :login]
#  skip_before_filter :auto_login, :only => [:tab]
  
  layout "f8/home"
  
  def login
    render :layout => false  
  end
   
  def tab
    @user = User.find_by_facebook_id(fbsession.user)
    @rounds = Round.list(:conditions => "user_id=#{@user.id}", :limit => 20)
    @courses = @user.saved_courses.collect { |sc| sc.course }
    @markers = @courses.select { |c| c.mappable? }.collect { |c| "#{c.latitude},#{c.longitude},tinyred" }
    @lifetime_stats = @user.lifetime_stats || UserStatSummary.new
    @stats = @user.stats || UserLast20StatSummary.new
      
    render :layout => false
  end
    
  def index
    @user = current_user
    @courses = @user.saved_courses.collect { |sc| sc.course }
    
    @friends = fbsession.friends_get_app_users(@user)
    if @friends.any?
      @users = User.find(:all, :conditions => ["facebook_id in (#{@friends.join(',')})"])
    else
      @users = []
    end

    @rounds = Round.list(:conditions => ["user_id in (?)", @users.collect { |u| u.id }])
    
    render :layout => 'f8/home'
  end

  def voyeur        
    @user = current_user
    @gstats = StatSummary.find_by_entity_id_and_name(0, "global")
    
    # optimized query to avoid n+1 sql calls and huge joins. probably over optimized a bit. oh well.
    @rounds = Round.find(
                     :all, 
                     :select => 'rounds.*, c.name, c.country, c.city, u.facebook_name, u.facebook_id, u.login', 
                     :joins => 'rounds use index (rounds_created_on), stat_summaries ss, courses c, users u ',
                     :conditions => 'ss.last_round = rounds.id and ss.type="UserStatSummary" and rounds.course_id=c.id and rounds.user_id=u.id and u.facebook_id is not null',
                     :order => 'rounds.created_on desc',
                     :limit => 20)

    facebook_ids = []
    @rounds.each do |r|
      facebook_ids << r.facebook_id unless r.facebook_id.nil?
    end

    fbsession.users_get_standard_info(facebook_ids)
    
    render :layout => 'f8/home'
  end
  
  def welcome
    render :layout => false
  end

  
end
