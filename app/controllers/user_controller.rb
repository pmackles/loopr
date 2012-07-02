class UserController < ApplicationController

  layout :userlayout 
  
  helper :stats, :round, :rounds, :saved_course

  def show
    blog
    render :action => 'blog'
  end

  def rounds
    @user = User.find(params[:id])
    @round_table = RoundTable.new([@user.id], params)
  end
    
  def courses
    @user = User.find(params[:id])
    @saved_courses = SavedCourse.user_course_list_summary(@user)
    @view = %w(map list).find { |v| v == params[:view] } || "map"
  end
  
  def rounds_summary
    @user = User.find(params[:id])
    @filter = RoundFilter.new(params_filter_with_defaults)
    summarizer = SqlRoundSummarizer.new(@filter)
    @summary = summarizer.summary
  end

  def rounds_stat
    @user = User.find(params[:id])
    @left = Metric.get((params[:metric] || "avg_18_hole_gross_score").to_sym)
    @right = "none"
    @filter = RoundFilter.new(params_filter_with_defaults)
    summarizer = SqlRoundSummarizer.new(@filter)
    @rounds = summarizer.rounds
    @summary = summarizer.summary
  end
   
  def handicap
    @user = User.find(params[:id])#    breadcrumb([ { :label => "Handicap"} ])

    eligible_rounds = Round.find(:all, 
                              :conditions => ['user_id=? and count_towards_handicap=1', @user], 
                              :limit => 40, 
                              :order => 'date_played desc')

    @handicapper = USGAHandicapper.new(eligible_rounds)
    @full_rounds = @handicapper.rounds
    @notes = [] # @handicapper.notes
    @ten_best = @handicapper.best
                              
  end
     
  def profile
    @user = User.find(params[:id])
    @stats = @user.stats || UserLast20StatSummary.new
    @lifetime_stats = @user.lifetime_stats || UserStatSummary.new
  end

  def groups
    @user = User.find(params[:id])
  end

  def feed
    @user = User.find_by_id_or_username(params)
    @rounds = @user.rounds.last(20)
    render :layout => false
  end
  
  def blog
    @user = User.find_by_id_or_username(params)
    if @user.nil?
      if logged_in?
        @user = User.find(current_user.id)
      else
        return login_required
      end
    end
    
    @stats = @user.stats || UserLast20StatSummary.new
    @lifetime_stats = @user.lifetime_stats || UserStatSummary.new
    
    @rounds = @user.rounds.last(20)
  end

  private
  def params_filter_with_defaults
    (params[:filter] || {}).reverse_merge(HashWithIndifferentAccess.new(:users => [@user]))
  end
end


