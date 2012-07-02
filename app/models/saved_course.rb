class SavedCourse < ActiveRecord::Base

  SAVE_TYPES = ["Played", "Wanna Play"]
  WANNA_PLAY = 1
  PLAYED = 0
  
  belongs_to :course
  belongs_to :user
#  has_many :rounds, :conditions
  
  has_many :rounds, :class_name => 'Round',
           :finder_sql => 'select * from rounds ' + 
                       'where user_id=#{user_id} and course_id=#{course_id} ' +
                       'order by date_played desc'

  has_one :stats, 
        :class_name => "SavedCourseStatSummary", 
        :foreign_key => "entity_id",
        :dependent => :destroy
        
  def self.find_by_user_and_course(user, course)
    SavedCourse.find(:first,
      :conditions => ["user_id=? and course_id=?", user.id, course.id])
  end

  def self.find_by_course(course)
    SavedCourse.find(:first,
      :conditions => ["course_id=?", course.id])
  end

  def self.user_course_list_summary(user)
    find(
      :all,
      :select => 'saved_courses.*, courses.name course_namex, courses.city course_city, courses.state course_state, courses.country course_country, courses.latitude course_latitude, courses.longitude course_longitude, rounds_played, scoring_average',
      :joins => "left outer join stat_summaries on (saved_courses.id=stat_summaries.entity_id and stat_summaries.type=\"SavedCourseStatSummary\") join courses on (saved_courses.course_id=courses.id)",
      :conditions => ['saved_courses.user_id=?', user.id],
      :order => 'courses.name'
    )
  end
   
  def course_name
    course.name
  end

  def course_name_and_state
    "#{course.name} - #{course.state}"
  end
  
#  def last_round
#    stats.last_round
#  end
  
  def has_played?
    stats != nil
  end
  
#  def low_round
#    return if stats == nil
#    stats.low_round
#  end
    
end
