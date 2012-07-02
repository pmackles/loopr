class Tee < ActiveRecord::Base

  belongs_to :course

  validates_presence_of :name, 
     :message => 'required'

  validates_uniqueness_of :name, :scope => [:course_id, :score_type],
    :message => 'There is already a tee with that name/type'

  validates_inclusion_of :yardage, :in => 500..9000, :allow_nil => true,
    :message => 'should be a number between 500 and 9000'
    
#  validates_inclusion_of :par, :in => 60..80, 
#    :message => 'should be a number between 60 and 80'

  validates_inclusion_of :mens_rating, :in => 20..80,
    :message => 'should be a number between 20 and 80'

#  validates_inclusion_of :mens_slope, :in => 50..150,
#    :message => 'should be a number between 50 and 150'

  def course_handicap(user)
    ((user.stats.handicap * self.mens_slope)/113).round
  end
  
  def color
    name.downcase.singularize
#    case name.downcase
#    when "blue" : color = "blue"
#    when "black" : color = "black"
#    when "red" : color = "red"
#    when "white" : color = "white"
#    else
#      color = name.downcase
#    end
  end
  
  def nine_hole?
    score_type == 2 || score_type == 3
  end
  
  def to_formatted_s (length_units = "yards")
    s = name
    if mens_rating || mens_slope || yardage
      s += " ("
      if mens_rating && mens_slope
        s += "#{mens_rating}/#{mens_slope}"
      elsif mens_rating
        s + "#{mens_rating}"
      end
      
      s += "; #{yardage} #{length_units}" if yardage
      s += ")"
    end
    s
  end
  
end
