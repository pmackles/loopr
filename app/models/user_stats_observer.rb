class UserStatsObserver < ActiveRecord::Observer
  observe Round

  def after_destroy(round)
    after_save(round)
  end
  
  def after_save(round)
    # user lifetime stats
    user = round.user
    uss = UserStatSummary.find_or_create_by_entity_id(user.id)
    uss.summarize_and_save

    # user recent stats
    ul20ss = UserLast20StatSummary.find_or_create_by_entity_id(user.id)
    ul20ss.summarize_and_save
        
    # user/course lifetime stats
    course = round.course
    sc = SavedCourse.find_or_create_by_course_id_and_user_id(course.id, user.id)
    SavedCourseStatSummary.find_or_create_by_entity_id(sc.id)
    SavedCourseStatSummary.summarize_and_save_all(user.id)
  
  end
end