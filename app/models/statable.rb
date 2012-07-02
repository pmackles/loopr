
module Statable
 
#  def formatted(attr)
#    val = self.send(attr)
#    return val if val.nil?
#	if val && attr.to_s.ends_with?("_percentage")
#	 formattedVal = "#{(val * 100).to_i}%"
#	elsif val && attr.to_s.ends_with?("_average") && val.class == Float
#	 formattedVal = sprintf("%01.2f", val)      
#    else
#	 formattedVal = "#{val}"
#	end
#  end
  
  ["one", "double_eagle", "eagle", "birdie", "par", "bogey", "dbl_bogey", "other", "gir", "zero_putt", "one_putt", "two_putt", "three_putt", "fourormore_putt"].each do |s|
    module_eval "def #{s}_percentage; (total_#{s}s / (total_holes_entered + 0.0)).round_to(2) unless total_#{s}s.nil? || total_holes_entered.nil?; end"
    
    [3, 4, 5].each do |p|
        module_eval "def par#{p}_#{s}_percentage; (par#{p}_#{s}s / (par#{p}_holes + 0.0)).round_to(2) unless par#{p}_#{s}s.nil? || par#{p}_holes == 0; end"
    end
  end
  
  def par3_over_under
    -((3 - par3_average) * par3_holes) unless par3_average.nil? || par3_holes == 0
  end

  def par4_over_under
    -((4 - par4_average) * par4_holes) unless par4_average.nil? || par4_holes == 0
  end

  def par5_over_under
    -((5 - par5_average) * par5_holes) unless par5_average.nil? || par5_holes == 0
  end
  
  def fairways_hit_percentage
    (fairways_hit / (total_fairways + 0.0)).round_to(2) unless total_fairways.nil? || total_fairways == 0
  end

  def average_drive
    total_tee_shot_distance / total_holes_with_distance unless total_holes_with_distance.nil? || total_holes_with_distance == 0
  end
  
  def total_average
    par_average
  end
  
  def putting_average_after_gir
    (total_putts_gir / (total_girs + 0.0)).round_to(2)  unless total_girs.nil? || total_girs == 0 || total_putts_gir.nil?
  end
  
#  def fairways_left_percentage
#    fairways_left / (total_fairways + 0.0) unless total_fairways.nil? || total_fairways == 0
#  end
#  
#  def fairways_right_percentage
#    fairways_right / (total_fairways + 0.0) unless total_fairways.nil? || total_fairways == 0
#  end
    
  def compare(attr, statable)
    a = self.send(attr)
	b = statable.send(attr)
#	return 0 if a.nil? || b.nil?
	
	order = StatSummary::STATS[attr][:order]
	if order == 1
	 return (a || 10000) <=> (b || 10000)
#      return a <=> b
	else
	 return (b || -1) <=> (a || -1)
#      return b <=> a
	end
  end
  
end
