class SavedCourseStatSummary < StatSummary
  
  belongs_to :saved_course, :foreign_key => :entity_id
  
  def self.summarize_and_save_all(user_id)
    ActiveRecord::Base.connection.update(
      "update stat_summaries ss, saved_courses sc left outer join " +
      "(select course_id, #{@@summary_sql} from rounds where user_id=#{user_id} group by course_id) r " +
      " on (sc.course_id=r.course_id) " +
      "set #{@@sql2} " +
      "where ss.type=\"SavedCourseStatSummary\" and ss.entity_id=sc.id and sc.user_id=#{user_id}"
    )   
  end
end