class RoundSummary
  include StatableX

  metric :total_rounds, :from => ["@data[:total_rounds]"]
  metric :total_holes, :from => ["@data[:total_holes]"]
  metric :total_distance, :from => ["@data[:total_distance]"]
  metric :total_unique_courses, :from => ["@data[:total_unique_courses]"]
  metric :total_strokes, :from => ["@data[:total_strokes]"]
  metric :total_penalty, :from => ["@data[:total_penalty]"]
  metric :avg_18_hole_gross_score, :from => ["@data[:avg_18_hole_gross_score]"]
  metric :avg_front_9_gross_score, :from => ["@data[:avg_front_9_gross_score]"]
  metric :avg_back_9_gross_score, :from => ["@data[:avg_back_9_gross_score]"]
  metric :total_18_hole_rounds, :from => ["@data[:total_18_hole_rounds].to_i"]
  metric :avg_18_hole_net_score, :from => ["@data[:avg_18_hole_net_score]"]
  metric :avg_18_hole_total_putts, :from => ["@data[:avg_18_hole_total_putts]"]

  metric :total_9_hole_rounds, :from => ["@data[:total_9_hole_rounds]"]
  metric :avg_9_hole_gross_score, :from => ["@data[:avg_9_hole_gross_score]"]
  metric :avg_9_hole_total_putts, :from => ["@data[:avg_9_hole_total_putts]"]

  metric :total_holes_entered, :from => ["@data[:total_holes_entered]"]
  metric :avg_par_3, :from => ["@data[:avg_par_3]"]
  metric :avg_par_4, :from => ["@data[:avg_par_4]"]
  metric :avg_par_5, :from => ["@data[:avg_par_5]"]
  metric :total_ones, :from => ["@data[:total_ones]"]
  metric :total_eagles, :from => ["@data[:total_eagles]"]
  metric :total_double_eagles, :from => ["@data[:total_double_eagles]"]
  metric :total_birdies, :from => ["@data[:total_birdies]"]
  metric :total_pars, :from => ["@data[:total_pars]"]
  metric :total_bogeys, :from => ["@data[:total_bogeys]"]
  metric :total_dbl_bogeys, :from => ["@data[:total_dbl_bogeys]"]
  metric :total_others, :from => ["@data[:total_others]"]
  
  metric :pct_birdies, :from => ["@data[:total_birdies].to_i", "@data[:total_holes_entered]"]
  metric :pct_pars, :from => ["@data[:total_pars].to_i", "@data[:total_holes_entered]"]
  metric :pct_bogeys, :from => ["@data[:total_bogeys].to_i", "@data[:total_holes_entered]"]
  metric :pct_dbl_bogeys, :from => ["@data[:total_dbl_bogeys].to_i", "@data[:total_holes_entered]"]
  metric :pct_others, :from => ["@data[:total_others].to_i", "@data[:total_holes_entered]"]
  
  metric :total_putts, :from => ["@data[:total_putts]"]
  metric :total_putts_gir, :from => ["@data[:total_putts_gir]"]
  metric :total_holes_with_putts, :from => ["@data[:total_holes_entered]"]
  metric :avg_putts_per_hole, :from => ["@data[:avg_putts_per_hole]"]
  metric :avg_putts_per_hole_after_gir, :from => ["@data[:total_putts_gir]", "@data[:total_girs]"]
  
  metric :total_zero_putts, :from => ["@data[:total_zero_putts]"]
  metric :total_one_putts, :from => ["@data[:total_one_putts]"]
  metric :total_two_putts, :from => ["@data[:total_two_putts]"]
  metric :total_three_putts, :from => ["@data[:total_three_putts]"]
  metric :total_fourormore_putts, :from => ["@data[:total_fourormore_putts]"]
  metric :pct_one_putts, :from => ["@data[:total_one_putts]", "@data[:total_holes_entered]"]
  metric :pct_two_putts, :from => ["@data[:total_two_putts]", "@data[:total_holes_entered]"]
  metric :pct_three_putts, :from => ["@data[:total_three_putts]", "@data[:total_holes_entered]"]
  metric :pct_fourormore_putts, :from => ["@data[:total_fourormore_putts]", "@data[:total_holes_entered]"]

  metric :total_girs, :from => ["@data[:total_girs]"]
  metric :pct_girs, :from => ["@data[:total_girs]", "@data[:total_holes_entered]"]
  metric :total_fairways, :from => ["@data[:total_fairways]"]
  metric :total_fairways_hit, :from => ["@data[:total_fairways_hit]"]
  metric :pct_fairways_hit, :from => ["@data[:total_fairways_hit]", "@data[:total_fairways]"]
  metric :avg_driving_distance, :from => ["@data[:total_driving_distance]", "@data[:total_holes_with_driving_distance]"]
  metric :max_driving_distance, :from => ["@data[:max_driving_distance]"]
  metric :total_driving_distance, :from => ["@data[:total_driving_distance]"]
  metric :total_holes_with_driving_distance, :from => ["@data[:total_holes_with_driving_distance]"]

  def initialize(data = {})
    @data = HashWithIndifferentAccess.new(data)
  end
  
  def user_id
    @data[:user_id]
  end
  
  def to_json
    h = Hash.new
    RoundSummary.metrics.each do |m|
      h[m.name] = send(m.name.to_s + "_formatted")
    end
    h[:user_id] = user_id
    
    h.to_json
  end
  
end

