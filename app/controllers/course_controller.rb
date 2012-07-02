require 'open-uri'
require "rexml/document"
    
class CourseController < ApplicationController
  layout "standard"

  helper :scorecard, :round, :rounds

#  model :scorecard
  
  before_filter :admin_only, :only => [:edit, :save, :update, :update_geo, :new, :create, :lock_tees, :destroy]
  skip_before_filter :auto_login, :only => [:auto_complete_for_course_name, :picker]
  
#  def blah
#    render :layout => false
#  end
  
  def auto_complete_for_course_name
    @value = params[:xxx]
    
    if @value.blank?
      @courses = []
    else
      @courses = Course.find(:all, 
        :conditions => [ 'LOWER(name) LIKE ?', '%' + @value.downcase + '%' ], 
        :order => 'name ASC',
        :limit => 51)
      if @courses.size > 50
        @too_many = true
        @courses.pop
      end
    end
    
    render :partial => 'courses'
  end
  
  def picker
    @saved_courses = if params[:qp] != "0"
      current_user.saved_courses.collect { |sc| sc.course }
    else
      []
    end
    
    @courses = []
    render :layout => false
  end
    
  def directions
    @course = Course.find(params[:id])
    address = @course.address.to_formatted_s
    headers["Status"] = "301 Moved Permanently"
    redirect_to "http://maps.google.com/maps?f=d&hl=en&geocode=&saddr=&daddr=#{URI.escape(address, /[\?&=\#%\s\/]/)}"
    return
  end

  def index
    headers["Status"] = "301 Moved Permanently"
    redirect_to(:controller => :courses)
    return
  end
  
  def reviews
    @course = Course.find(params[:id])
    @address = @course.address
    @saved_course = SavedCourse.find_or_initialize_by_user_id_and_course_id(
      current_user.id, params[:id], 
      :save_type => params[:save_type] || 1
    )
        
    @reviews = CourseReview.paginate(
      :conditions => "type_id=#{@course.id}",
      :order => "created_at desc", 
      :page => params[:page] || 1, 
      :per_page => 100,
      :finder => :list
    )
    
    render :layout => :courselayout                               
  end
  
  def scorecard
    @course = Course.find(params[:id])
    respond_to do |format|
      format.js { 
        render :json => {
          :tees => @course.tees.collect { |t| 
            {
              :id => t.id, 
              :name => t.name,
              :mens_rating => t.mens_rating,
              :mens_slope => t.mens_slope,
	  	        :yardage => t.yardage,
	  	        :score_type => t.score_type
            } 
          },
          
          :holes => @course.holes.collect { |h|
            { 
              :par => h.par
            }  
          },
          
          :name => @course.name,
          :city => @course.address.city,
          :state => @course.address.state,
          :country => @course.address.country,
          :has_slope => @course.has_slope,
          :length_units => @course.length_units,
          :rating_system => @course.rating_system
        }.to_json 
      }
    end
  end
  
  def aerial
    @course = Course.find(params[:id])
    breadcrumb({:label => "Aerial"})
    
    if @course.latitude && @course.longitude
      @latitude = @course.latitude
      @longitude = @course.longitude
      @zoom = 16
    else
      # view of continental US
      @latitude = 38.479395
      @longitude = -97.382812
      @zoom = 3
    end
    
    render :layout => 'stretch'
  end
  
  def rounds
    @course = Course.find(params[:id])
    @address = @course.address
    @saved_course = SavedCourse.find_or_initialize_by_user_id_and_course_id(
      current_user.id, params[:id], 
      :save_type => params[:save_type] || 1
    )
    
    @rounds = Round.paginate(
      :conditions => ['course_id=?', @course.id],
      :order => "date_played desc", 
      :page => params[:page] || 1, 
      :per_page => 40,
      :finder => :list
    )
    
    render :layout => :courselayout
  end
  
  def show
    @course = Course.find(params[:id])
    if params[:name].blank?
      headers["Status"] = "301 Moved Permanently"
      redirect_to(course_url(:id => @course, :name => @course.name))
      return
    end
    @address = @course.address   
    @saved_course = SavedCourse.find_or_initialize_by_user_id_and_course_id(
      current_user.id, params[:id], 
      :save_type => params[:save_type] || 1
    )
    
    @review = CourseReview.find_by_type_id_and_user_id(@course.id, current_user.id)
    @rounds = Round.list(:conditions => "course_id=#{@course.id}", :limit => 8)
    @reviews = CourseReview.list(:conditions => "type_id=#{@course.id}", :limit => 3)
    
    render :layout => :courselayout
  end


  def update_geo 
    course = Course.find(params[:id])    
    course.latitude = params[:lat]
    course.longitude = params[:lng]
    course.zoom = params[:zoom]
    course.save!
    
    render :status => 200, :nothing => true
  end

  def lock_tees 
    @course = Course.find(params[:id])    
    @course.status = params[:status] || Course::COMPLETE
    @course.save!
    
    render :partial => 'tee/tee_status'
  end
  
  def edit
    @course = Course.find(params[:id])
    @region = Geography::Region.find_by_country_and_subdivision(@course.country, @course.state)
    logger.debug("xxx #{@region.inspect}, #{@course.country}, #{@course.state}") 
  end

  def update
    @course = Course.find(params[:id])
    @course.attributes = params[:course]
    @region = Geography::Region.find_by_name(params[:region][:name])
 
    if @course.save
      flash[:notice] = 'Course was successfully updated.'
      redirect_to :action => 'show', :id => @course
    else
      render :action => 'edit'
    end
  end

  def new
    if params[:id]
      @course = Course.find(params[:id])
      @region = Geography::Region.find_by_country_and_subdivision(@course.country, @course.state)
    else
      @course = Course.new(params[:course])
      @course.club_type = nil
      @course.fee_range = nil
    end
    @course.status = Course::COMPLETE
  end
    
  def create
    @course = Course.new(params[:course])
    @course.created_by = current_user
    @region = Geography::Region.find_by_name(params[:region][:name]) if params[:region]
        
    if @course.save
      flash[:notice] = 'Course was successfully created.'
      redirect_to :action => 'show', :id => @course
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @course = Course.find(params[:id])
    @rounds = Round.find_all_by_course_id(@course.id)
    @saved_courses = SavedCourse.find_all_by_course_id(@course.id)
    
    if request.post?
      if @rounds.any? || @saved_courses.any?
        to_course_id = params[:to_course_id]
        return if to_course_id.blank?
        
        Round.update_all("course_id=#{to_course_id}", "course_id=#{@course.id}")
        SavedCourse.update_all("course_id=#{to_course_id}", "course_id=#{@course.id}")
      end
      @course.destroy
      redirect_to :controller => :courses, :action => :browse
      return
    end   
  end
  
  protected

  def breadcrumb(crumb = nil)
    @breadcrumb = [
      {
        :label => @course.name,
        :url => { :controller => 'course', :action => 'show', :id => @course }
      }
    ]

    @breadcrumb[1] = crumb unless crumb.nil?

    @description = "Complete information on #{@course.name} in #{@course.city}, #{@course.state} including aerial shots, ratings, driving directions and more."
    @keywords = "#{@course.name}, #{@course.city} golf courses, #{@course.state} golf courses, #{@course.name} driving directions, #{@course.name} tips, #{@course.name} pictures, #{@course.name} reviews"

    @breadcrumb 
  end
  
end
