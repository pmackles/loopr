class ScorecardBang
#  attr_accessor :holes
  
  def initialize(number_of_holes = 18)
    @holes = Array.new(number_of_holes) do |i|
      Hole.new(:number => i)
    end
  end
 
  def holes
    @holes
  end
   
  def holes=(copyfrom)
    @holes.each_with_index do |h, i|
      h.par = copyfrom[i].par if copyfrom[i]
    end
  end
  
  def valid?
    all_valid = true
    @holes.each do |h| 
      all_valid = false unless h.valid?
    end
    all_valid
  end
  
  def save(course)
    return false unless valid?
    
    if course.holes.empty?
      course.holes = @holes
    else
      keys = course.holes.collect { |h| h.id }
      values = @holes.collect { |h| { :par => h.par } }
      Hole.update(keys, values)
    end
  end
  
end
