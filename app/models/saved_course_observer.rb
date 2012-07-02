class SavedCourseObserver < ActiveRecord::Observer
  observe Round
  
#  def after_destroy(round)
#    round.logger.debug("in SavedCourseObserver.after_destroy")
#    user = round.user
#    course = round.course
#    sc = user.saved_courses.find_by_course(course)
#    
#    if sc
#      stats = sc.stats
#      round.logger.debug("in SavedCourseObserver.after_destroy... sc=#{sc.course.name}; stats=#{stats}")
#      if stats
#        stats.summarize
#        if stats.rounds_played.nil? || stats.rounds_played == 0
#          sc.destroy
#        else
#          stats.save
#        end
#      end
#    end
#    round.logger.debug("done with SavedCourseObserver.after_destroy")  
#  end
#
#  def after_update(round)
#    round.logger.debug("in SavedCourseObserver.after_update")
#    user = round.user
#    course = round.course
#    sc = user.saved_courses.find_by_course(course) ||  
#      user.saved_courses.build( :course => course)
#    sc.save_type = 0
#    sc.save
#    
#    sc.stats || sc.create_stats(:name => 'for_course')  
#
#    # in case they changed courses, need to loop over all courses. not ideal
#    user.saved_courses.of_type(0).each { |sc|
#      stats = sc.stats
#      round.logger.debug("in SavedCourseObserver.after_update... sc=#{sc.course.name}; stats=#{stats}")
#      if stats
#        stats.summarize
#        if stats.rounds_played.nil? || stats.rounds_played == 0
#          sc.destroy
#        else
#          stats.save
#        end
#      end
#    }
#    
#    round.logger.debug("done with SavedCourseObserver.after_update")  
#  end
#    
#  def after_create(round)
#    round.logger.debug("in SavedCourseObserver.after_create")
#    user = round.user
#    course = round.course
#    sc = user.saved_courses.find_by_course(course) ||  
#      user.saved_courses.build( :course => course)
#    sc.save_type = 0
#    sc.save
#    
#    sc.stats || sc.create_stats(:name => 'for_course')  
#    sc.stats.summarize
#    sc.stats.save
#    
#    round.logger.debug("done with SavedCourseObserver.after_create")    
#  end
end