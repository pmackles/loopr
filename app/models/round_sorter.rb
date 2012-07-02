class RoundSorter
  def self.load(conditions)
    results = ActiveRecord::Base.connection.select_one(
      "select count(1) as rounds_played," +
      "  avg(par5_average) as par5_average, " + 
      "  avg(par4_average) as par4_average, " + 
      "  avg(par3_average) as par3_average, " + 
      "  avg(putting_average) as putting_average, " +
      "  sum(r.total_holes) as total_holes, " +
      "  sum(total_ones) as total_ones, " + 
      "  sum(total_eagles) as total_eagles, " +
      "  sum(total_birdies) as total_birdies, " + 
      "  sum(total_pars) as total_pars, " + 
      "  sum(total_bogeys) as total_bogeys, " +
      "  sum(total_others) as total_others, " +
      "  sum(r.total_girs) as total_girs, " + 
      "  sum(r.total_score) as total_strokes, " +
      "  sum(r.total_putts) as total_putts, " +
      "  sum(r.total_score) as total_strokes, " +
      "  avg(r.total_penalty) as penalty_average, " +
      "  sum(r.total_penalty) as total_penalty, " +
      "  avg(par3_putting_average) as par3_putting_average, " +
      "  sum(r.par3_one_putts) as par3_one_putts, " +
      "  sum(r.par3_two_putts) as par3_two_putts, " +
      "  sum(r.par3_three_putts) as par3_three_putts, " +
      "  sum(r.par3_fourormore_putts) as par3_fourormore_putts, " +
      "  sum(r.par3_birdies) as par3_birdies, " +
      "  sum(r.par3_pars) as par3_pars, " + 
      "  sum(r.par3_bogeys) as par3_bogeys, " + 
      "  sum(r.par3_others) as par3_others, " + 
      "  sum(r.par3_girs) as par3_girs, " +
      "  sum(r.par3_holes) as par3_holes, " +
      "  sum(r.par3_penalty) as par3_penalty, " +
      "  avg(par4_putting_average) as par4_putting_average, " +
      "  sum(r.par4_one_putts) as par4_one_putts, " +
      "  sum(r.par4_two_putts) as par4_two_putts, " +
      "  sum(r.par4_three_putts) as par4_three_putts, " +
      "  sum(r.par4_fourormore_putts) as par4_fourormore_putts, " +
      "  sum(r.par4_birdies) as par4_birdies, " +
      "  sum(r.par4_pars) as par4_pars, " + 
      "  sum(r.par4_bogeys) as par4_bogeys, " + 
      "  sum(r.par4_others) as par4_others, " + 
      "  sum(r.par4_girs) as par4_girs, " +
      "  sum(r.par4_holes) as par4_holes, " +
      "  sum(r.par4_penalty) as par4_penalty, " +
      "  avg(par5_putting_average) as par5_putting_average, " +
      "  sum(r.par5_one_putts) as par5_one_putts, " +
      "  sum(r.par5_two_putts) as par5_two_putts, " +
      "  sum(r.par5_three_putts) as par5_three_putts, " +
      "  sum(r.par5_fourormore_putts) as par5_fourormore_putts, " +
      "  sum(r.par5_birdies) as par5_birdies, " +
      "  sum(r.par5_pars) as par5_pars, " + 
      "  sum(r.par5_bogeys) as par5_bogeys, " + 
      "  sum(r.par5_others) as par5_others, " + 
      "  sum(r.par5_girs) as par5_girs, " +
      "  sum(r.par5_holes) as par5_holes, " +
      "  sum(r.par5_penalty) as par5_penalty, " +
      "  sum(r.total_holes_entered) as total_holes_entered, " +
      "  avg(par_average) as par_average, " +
      "  sum(r.total_one_putts) as total_one_putts, " +
      "  sum(r.total_two_putts) as total_two_putts, " +
      "  sum(r.total_three_putts) as total_three_putts, " +
      "  sum(r.total_fourormore_putts) as total_fourormore_putts " +
      " from rounds r " + (conditions ? "where #{conditions}" : "")
    )
  end
end
