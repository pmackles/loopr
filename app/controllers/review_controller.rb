class ReviewController < ApplicationController
  before_filter :login_required
  
  def login_required
     unless logged_in?
      render(:nothing => true, :status => 403)
      return false
     end
  end

  def new
    course = Course.find(params[:id])
    @review = CourseReview.new
    @review.course = course
    @review.rating = nil
  end

  def create
    @review = CourseReview.new(params[:review])
    @review.user = current_user
    if @review.body.blank?
      @review.body = nil
      @review.status = 1
    else
      @review.status = 0
    end
    
    if @review.save
      render :text => { :saved => true }.to_json
    else
      render :text => { 
        :saved => false, 
        :errors => @review.errors.full_messages 
      }.to_json
      
#      render :action => 'new'
    end
  end
  
end
