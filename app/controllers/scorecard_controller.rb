class ScorecardController < ApplicationController
  layout "standard"
  
  before_filter :admin_only
    
  def edit
    @course = Course.find(params[:id])
    @scorecard = @course.scorecard
    
    if request.post?
      holes = params[:holes] || {}
      @scorecard.holes.each { |h| h.attributes = holes[h.number.to_s] }
      redirect_to :controller => 'course', :action => 'show', :id => @course if @scorecard.save(@course)
    end
  end

end
