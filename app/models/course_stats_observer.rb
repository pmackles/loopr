class CourseStatsObserver < ActiveRecord::Observer
  observe Round
  
  def after_destroy(round)
    after_save(round)
  end
  
  def after_save(round)
    user = round.user
    course = round.course
    
    unless course.complete_with_tees?
      tee = course.tees.find_by_name_and_score_type(round.tee_name, round.score_type) || 
        course.tees.create(
          :name => round.tee_name.capitalize,
          :mens_rating => round.tee_rating, 
          :mens_slope => round.tee_slope,
          :yardage => round.tee_yardage,
          :score_type => round.score_type,
          :created_by => round.user)
      tee.logger.info("tried creating tee... #{tee.name}/#{tee.score_type} valid: #{tee.valid?}")
    end
    
    if course.holes.empty? && round.detailed? && round.total_holes_entered == 18
      course.holes = Array.new(18) { |i|
        Hole.new(:number => i, :par => round.scores[i].par)
      }
    end         

  end
end

