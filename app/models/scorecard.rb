class Scorecard
  attr_accessor :course, :rounds, :show_name, :show, :date
  
  def initialize
    @show_name = false
  end
  
  def show_name?
    @show_name
  end

#  def hole_range
#    self.show.include?('holes') ? 0..17 : 0...0
#  end
  
  def holes
    round_holes = @rounds[0].scores.collect { |s| s }
    course_holes = @course.holes.collect { |h| h }

    arr = Array.new(18) do |index|
      if round_holes[index] && round_holes[index].par
        round_holes[index] 
      elsif course_holes[index] && course_holes[index].par
        course_holes[index]
      else
        Hole.new
      end
    end
    arr 
  end

  def total_par(range = 0..17)
    total = 0 
    holes[range].each { |h| total += h.par unless h.par.nil? }
    total == 0 ? nil : total
  end

  def total_score(round, range = 0..17)
    total = rounds[round].total_score(range)
    total == 0 ? nil : total
  end
    
  def tees
    @tees ||= @rounds.group_by do |r| 
      "#{r.tee_name} (#{r.tee_rating}" +
      "#{r.tee_slope ? '/' + r.tee_slope.to_s : ''}; #{r.tee_yardage} #{r.course.length_units})"
    end
  end
  
end
