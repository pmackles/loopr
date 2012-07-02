module CourseHelper
  def post_round_for_course_link(course, label)
    link_to(label, round_new_url('course[id]' => course), :onclick => 'return checkForLogin();')
  end

  def review_course_link(course, label)
    link_to_remote_redbox(
      label, 
      :condition => 'checkForLogin()', 
      :url => { :controller => 'review', :action => 'new', :id => course}
    )
  end
end
