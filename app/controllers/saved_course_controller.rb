class SavedCourseController < ApplicationController
  
  helper :user
  before_filter :login_required
  skip_before_filter :auto_login
    
  def new
    sc = SavedCourse.find_or_create_by_user_id_and_course_id(
      current_user.id, params[:id], 
      :save_type => params[:save_type] || 1
    )

    render :partial => 'add_course_button', :object => sc
  end

  
  def add_course
    @user = current_user
    SavedCourse.find_or_create_by_user_id_and_course_id(
      current_user.id, params[:id], 
      :save_type => params[:save_type] || 1
    )

    render :partial => "course_list", 
      :object => SavedCourse.user_course_list_summary(current_user), 
      :locals => { :editable => true }
  end
  
  def remove_course
    @user = current_user
    course = Course.find(params[:id])
    if sc = SavedCourse.find_by_user_and_course(current_user, course)
      sc.destroy
    end
    
    render :partial => "course_list", 
      :object => SavedCourse.user_course_list_summary(current_user), 
      :locals => { :editable => true }
  end
  
end
