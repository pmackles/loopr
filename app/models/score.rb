class Score < ActiveRecord::Base
  DOUBLE_EAGLE = -3
  EAGLE = -2
  BIRDIE = -1
  PAR = 0
  BOGEY = 1
  DBL_BOGEY = 2
  
  CLUBS = [
    ["Driver", "DR"],
    ["3 Wood", "3W"],
    ["4 Wood", "4W"],
    ["5 Wood", "5W"],
    ["7 Wood", "7W"],
    ["1 Iron", "1I"],
    ["2 Iron", "2I"],
    ["3 Iron", "3I"],
    ["4 Iron", "4I"],
    ["5 Iron", "5I"],
    ["6 Iron", "6I"],
    ["7 Iron", "7I"],
    ["8 Iron", "8I"],
    ["9 Iron", "9I"],
    ["P Wedge", "PW"],
    ["S Wedge", "SW"],
    ["L Wedge", "LW"],
    ["G Wedge", "GW"],
    ["1 Hybrid", "1H"],
    ["2 Hybrid", "2H"],
    ["3 Hybrid", "3H"],
    ["4 Hybrid", "4H"],
    ["5 Hybrid", "5H"]
  ]

  DIRECTIONS = [
    ["Hit Fairway/Green", 0],
    ["Missed", 4], 
    ["Missed Left", -1],
    ["Missed Right", 1],
    ["Missed Short",2],
    ["Missed Long", 3],    
  ]
    
  belongs_to :round
  
  def fairway?
    !fairway.blank? && par != 3
  end
  
  def fairway_hit?
    fairway? && fairway == 0
  end
  
  def driver?
    "DR" == tee_shot_club
  end
  
  def tee_shot_distance?
    !tee_shot_distance.blank?
  end
  
  def tee_shot_distance=(distance)
    if (distance.match(/^[0-9]+$/) && (0..500).include?(distance.to_i))
      write_attribute(:tee_shot_distance, distance.to_i)
    else
      write_attribute(:tee_shot_distance, nil)
    end
  end
  
  def over_under_par 
    score - par
  end
  
  def complete?
    par && score && putts
  end
  
  def gir?
    complete? ? par - 2 >= score - putts : false
  end
  
  def reset
    self.score = nil
    self.putts = nil
    self.over_under_par = nil
    self.penalty_strokes = nil
    self.gir = nil
    self.par = nil
  end
  
end
