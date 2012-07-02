class TeeController < ApplicationController
  
  layout "standard"
  
  helper :scorecard
  
  before_filter :admin_only, :only => [:edit, :save, :update, :new, :create, :destroy, :list]

  def index
    list
    render :action => 'list'
  end

  def list
    @courses = Course.find(:all, 
                           :joins => "left outer join rounds on rounds.course_id=courses.id", 
                           :conditions => "status in (0,1)", 
                           :order => "rounds.created_on desc",
                           :limit => 100)
  end

  def show
    @tee = Tee.find(params[:id])
  end

  def new
    @tee = Tee.new
    @course = Course.find(params[:course][:id])
  end

  def create
    @tee = Tee.new(params[:tee])
    @tee.created_by = current_user
    @course = @tee.course
    if @tee.save
      redirect_to :action => 'edit', :id => @course
      return
    end
    
    render :action => 'edit', :id => @course
  end

  def edit
    @course = Course.find(params[:id])
    @tee = Tee.new(:course => @course)
  end

#  def update
#    @tee = Tee.find(params[:id])
#    course = @tee.course
#    @tee.update_attributes(params[:tee])
#    render :partial => 'course_tee_list', :locals => { :tees => course.tees}
#  end

  def destroy
    t = Tee.find(params[:id])
    @course = t.course
    t.destroy
    render(:partial => 'tee_list', :locals => { :course => @course, :edit_mode => true })
  end
end
