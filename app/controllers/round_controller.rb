class RoundController < ApplicationController

  before_filter :login_required, :except => [:list, :show, :index, :iframe]
  skip_before_filter :auto_login, :only => [:create, :update]
  
  layout :standardlayout

  helper :scorecard, :stats, :tee
    
  def iframe
    load_round
    render :layout => false
  end
  
  def show
    begin
      load_round
    rescue ActiveRecord::RecordNotFound
      render :action => 'show_deleted', :layout => false
      return
    end
    
    render :layout => :userlayout
  end
      
  def new

    @round = Round.new
    
    if params[:course] && params[:course][:id]
      @course = Course.find(params[:course][:id])
    end
    
#    @holes = @course.holes
    @scores = @round.scores
#    @tees = @course.tees

    @round.score_type = 0
    @round.details = 1
    @round.count_towards_handicap = 1
    @round.handicap = current_user.handicap
    @user = current_user
  end

  def create
    @round = Round.new(params[:round])
    @round.user = @user = current_user

    if @round.detailed?
      @round.scores.each { |s|
        s.attributes = params[:score][s.hole.to_s] if params[:score]
      }
    end
    
    @scores = @round.scores
        
    begin
      save
#      FacebookPublisher.publish_new_round(@round)
    rescue ActiveRecord::RecordInvalid => invalid
      render :json => { :saved => false, :errors => @round.errors.full_messages, :id => nil}.to_json
      return
    end

  end

  def update
    @round = Round.find(params[:id])    
    if !@round.authorized?(current_user)
      redirect_to :action => 'show', :id => @round
      return
    end
    
    @round.attributes = params[:round]

    if @round.detailed?
      @round.scores.each { |s|
        s.attributes = params[:score][s.hole.to_s]
      }
    end

    @scores = @round.scores
    @user = @round.user
    
    begin
      save
    rescue ActiveRecord::RecordInvalid => invalid
      render :json => { :saved => false, :errors => @round.errors.full_messages, :id => @round.id}.to_json
      return
    end
    
  end

  def edit
    @round = Round.find(params[:id])

    if !@round.authorized?(current_user)
      redirect_to :action => 'show', :id => @round
      return
    end

    @course = @round.course
    @scores = @round.scores
    @user = @round.user
  end
  
  def destroy
    @round = Round.find(params[:id])

    if !@round.authorized?(current_user)
      redirect_to :action => 'show', :id => @round
      return
    end
    
    @round.destroy

    FacebookPublisher.update_profile(@round.user)
    
    render :text => "<script>top.location.href='#{blog_url(:id => current_user)}';</script>"
  end
  
  protected
  
  def load_round
    @round = Round.find(params[:id])
    @saved_course = 
      SavedCourse.find_by_user_and_course(@round.user, @round.course)
    @user = @round.user
    @course = @round.course
    
    @scorecard = @round.scorecard
    @outings = [] # @round.outings
  end
  
  def save

    logger.debug("in RC.save")
    
    unless params[:course].nil? || params[:course][:id].blank?
      @course = Course.find(params[:course][:id])
    end
        
    Round.transaction do        
      @round.course = @course
      @round.save!   
    end

    FacebookPublisher.update_profile(@round.user)

    render :json => { :saved => true, :errors => [], :id => @round.id}.to_json   
#    render :text => "<script>top.location.href='#{round_url(:id => @round)}';</script>"
  end
    
end
