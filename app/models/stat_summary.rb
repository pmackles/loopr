class StatSummary < ActiveRecord::Base
    
  include StatableX
  
  metric :total_rounds, :from => [:rounds_played]
  metric :total_9_hole_rounds
  metric :total_holes_entered
  metric :avg_18_hole_gross_score, :from => [:scoring_average]
  metric :avg_9_hole_gross_score
  metric :avg_18_hole_net_score, :from => [:net_score]
  metric :avg_par_3, :from => [:par3_average]
  metric :avg_par_4, :from => [:par4_average]
  metric :avg_par_5, :from => [:par5_average]
  metric :total_girs
  metric :pct_girs, :from => [:total_girs, :total_holes_entered]
  metric :total_holes_with_putts, :from => [:total_holes_entered]
  metric :avg_putts_per_hole, :from => [:putting_average]
  metric :avg_putts_per_hole_after_gir, :from => [:total_putts_gir, :total_girs]
  metric :total_fairways
  metric :total_fairways_hit, :from => [:fairways_hit]
  metric :pct_fairways_hit, :from => [:fairways_hit, :total_fairways]
  metric :avg_driving_distance, :from => [:total_driving_distance, :total_holes_with_driving_distance]
  metric :max_driving_distance
  metric :total_ones
  metric :total_eagles
  metric :total_double_eagles
  metric :total_birdies
  metric :total_pars
  metric :total_bogeys
  metric :total_dbl_bogeys
  metric :total_others
  metric :total_holes
  metric :total_strokes
  
  metric :pct_birdies, :from => [:total_birdies, :total_holes_entered]
  metric :pct_pars, :from => [:total_pars, :total_holes_entered]
  metric :pct_bogeys, :from => [:total_bogeys, :total_holes_entered]
  metric :pct_dbl_bogeys, :from => [:total_dbl_bogeys, :total_holes_entered]
  metric :pct_others, :from => [:total_others, :total_holes_entered]

  metric :total_zero_putts
  metric :total_one_putts
  metric :total_two_putts
  metric :total_three_putts
  metric :total_fourormore_putts
  metric :pct_one_putts, :from => [:total_one_putts, :total_holes_entered]
  metric :pct_two_putts, :from => [:total_two_putts, :total_holes_entered]
  metric :pct_three_putts, :from => [:total_three_putts, :total_holes_entered]
  metric :pct_fourormore_putts, :from => [:total_fourormore_putts, :total_holes_entered]
  
  @@summary_sql = [
    Metric.avg_18_hole_gross_score.sql, 
    Metric.total_9_hole_rounds.sql, 
    Metric.avg_9_hole_gross_score.sql, 
    Metric.avg_putts_per_hole.sql,
    Metric.total_rounds.sql,
    Metric.avg_front_9_gross_score.sql,
    Metric.avg_back_9_gross_score.sql,
    Metric.avg_par_5.sql,
    Metric.avg_par_4.sql,
    Metric.avg_par_3.sql,
    Metric.avg_18_hole_total_putts.sql,
    Metric.total_others.sql,
    Metric.total_putts.sql,
    Metric.total_birdies.sql,
    Metric.total_bogeys.sql,
    Metric.total_strokes.sql,
    Metric.total_eagles.sql,
    Metric.total_pars.sql,
    Metric.total_ones.sql,
    Metric.total_girs.sql,
    Metric.total_holes.sql,
    Metric.total_dbl_bogeys.sql,
    Metric.total_holes_entered.sql,
    Metric.total_zero_putts.sql,
    Metric.total_one_putts.sql,
    Metric.total_two_putts.sql,
    Metric.total_three_putts.sql,
    Metric.total_fourormore_putts.sql,
    Metric.total_penalty.sql,
    Metric.total_fairways.sql,
    Metric.total_fairways_hit.sql,
    Metric.max_driving_distance.sql,
    Metric.total_driving_distance.sql,
    Metric.total_holes_with_driving_distance.sql,
    Metric.avg_18_hole_net_score.sql,
    Metric.total_putts_gir.sql
  ].join(", ")

  @@sql2 = [
    "ss.scoring_average=r.avg_18_hole_gross_score",
    "ss.total_9_hole_rounds = r.total_9_hole_rounds",
    "ss.avg_9_hole_gross_score = r.avg_9_hole_gross_score",
    "ss.putting_average = r.avg_putts_per_hole",
    "ss.rounds_played = r.total_rounds",
    "ss.front9_average = r.avg_front_9_gross_score",
    "ss.back9_average = r.avg_back_9_gross_score",
    "ss.par5_average = r.avg_par_5",
    "ss.par4_average = r.avg_par_4",
    "ss.par3_average = r.avg_par_3",
    "ss.total_putts_average = r.avg_18_hole_total_putts",
    "ss.total_others = r.total_others",
    "ss.total_putts = r.total_putts",
    "ss.total_birdies = r.total_birdies",
    "ss.total_bogeys = r.total_bogeys",
    "ss.total_strokes = r.total_strokes",
    "ss.total_eagles = r.total_eagles",
    "ss.total_pars = r.total_pars",
    "ss.total_ones = r.total_ones",
    "ss.total_girs = r.total_girs",
    "ss.total_holes = r.total_holes",
    "ss.total_dbl_bogeys = r.total_dbl_bogeys",
    "ss.total_holes_entered = r.total_holes_entered",
    "ss.total_zero_putts = r.total_zero_putts",
    "ss.total_one_putts = r.total_one_putts",
    "ss.total_two_putts = r.total_two_putts",
    "ss.total_three_putts = r.total_three_putts",
    "ss.total_fourormore_putts = r.total_fourormore_putts",
    "ss.total_penalty = r.total_penalty",
    "ss.total_fairways = r.total_fairways",
    "ss.fairways_hit = r.total_fairways_hit",
    "ss.max_driving_distance = r.max_driving_distance",
    "ss.total_driving_distance = r.total_driving_distance",
    "ss.total_holes_with_driving_distance = r.total_holes_with_driving_distance",
    "ss.net_score = r.avg_18_hole_net_score",
    "ss.total_putts_gir = r.total_putts_gir"
  ].join(", ")

  def self.reload
    UserStatSummary.find(:all).each { |s| s.summarize; s.save }
    UserLast20StatSummary.find(:all).each { |s| s.summarize; s.save }
    CourseStatSummary.find(:all).each { |s| s.summarize; s.save }
    SavedCourseStatSummary.find(:all).each { |s| s.summarize; s.save }
  end
 
end
