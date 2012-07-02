class Outing
  attr_reader :date_played, :course_id, :course_name, :total_holes
  
  def initialize(date_played, course_id, course_name, total_holes)
    @date_played = date_played
    @course_id = course_id
    @course_name = course_name
    @total_holes = total_holes
  end
  
  def eql?(o)
    o.is_a?(Outing) && date_played == o.date_played && course_id = o.course_id && total_holes = o.total_holes
  end
  
  def hash
    date_played.hash + course_id.hash + total_holes.hash
  end
  
end
