class SqlRoundSummarizer

  
  def initialize(filter)
    @filter = filter
  end
  
  def rounds(page = nil)
    if @filter.limit?
      Round.find(:all, :conditions => conditions, :order => "date_played desc", :include => :course, :limit => 20).reverse
    else
      if page
        Round.paginate(:all, :conditions => conditions, :order => "date_played", :include => :course, :page => page)
      else
        Round.find(:all, :conditions => conditions, :order => "date_played", :include => :course)
      end
    end
  end
  
  def min(attr)
    Round.find(:first, :conditions => conditions, :order => attr, :limit => 1)
  end
  
  def max(attr)
    Round.find(:first, :conditions => conditions, :order => "#{attr} desc", :limit => 1)
  end
  
  def last()
    Round.find(:first, :conditions => conditions, :order => "date_played desc", :limit => 1)
  end
  
  def summary()
 
    join = if @filter.limit?
      "rounds r join (" +
      @filter.users.collect { |u| "(select id from rounds where user_id=#{u} order by date_played desc limit 20)" }.join(" union ") +
      ") t on r.id=t.id"
    else
      "rounds r"
    end
    
    result = ActiveRecord::Base.connection.select_all(
      "select #{group_by_columns}" +  
      "  sum(1) as total_rounds," +
      "  sum(case total_holes when 18 then 1 else 0 end) as total_18_hole_rounds, " +
      "  sum(case total_holes when 9 then 1 else 0 end) as total_9_hole_rounds, " +
      "  sum(details) as total_detailed_rounds," +
      "  count(distinct course_id) as total_unique_courses," + 
      "  sum(tee_yardage) as total_distance," + 
      "  truncate(avg(case total_holes when 18 then r.total_score else null end), 2) as avg_18_hole_gross_score," +
      "  truncate(avg(case total_holes when 18 then r.total_score - r.course_handicap else null end), 2) as avg_18_hole_net_score," +
      "  truncate(avg(case total_holes when 18 then r.total_putts else null end), 2) as avg_18_hole_total_putts," +
      "  truncate(avg(case total_holes when 18 then total_front9 else null end), 2) as avg_front_9_gross_score, " + 
      "  truncate(avg(case total_holes when 18 then total_back9 else null end), 2) as avg_back_9_gross_score, " +
      "  truncate(avg(case total_holes when 9 then r.total_score else null end), 2) as avg_9_hole_gross_score," +
      "  truncate(avg(case total_holes when 9 then r.total_putts else null end), 2) as avg_9_hole_total_putts," +     
      "  truncate(sum(par5_average*par5_holes)/sum(par5_holes), 2) as avg_par_5, " + 
      "  truncate(sum(par4_average*par4_holes)/sum(par4_holes), 2) as avg_par_4, " + 
      "  truncate(sum(par3_average*par3_holes)/sum(par3_holes), 2) as avg_par_3, " +
      "  truncate(sum(putting_average*total_holes_entered)/sum(total_holes_entered), 2) as avg_putts_per_hole, " +
      "  sum(r.total_holes) as total_holes, " +
      "  sum(total_ones) as total_ones, " + 
      "  sum(total_eagles) as total_eagles, " +
      "  sum(total_double_eagles) as total_double_eagles, " +
      "  sum(total_birdies) as total_birdies, " +
      "  sum(total_pars) as total_pars, " +
      "  sum(total_bogeys) as total_bogeys, " +
      "  sum(total_dbl_bogeys) as total_dbl_bogeys, " +
      "  sum(total_others) as total_others, " +
      "  sum(r.total_girs) as total_girs, " + 
      "  sum(r.total_holes_entered) as total_holes_with_girs, " +
      "  sum(r.total_score) as total_strokes, " +
      "  sum(r.total_putts) as total_putts, " +
      "  truncate(avg(r.total_penalty), 2) as penalty_average, " +
      "  sum(r.total_penalty) as total_penalty, " +
      "  sum(r.total_holes_entered) as total_holes_entered, " +
      "  sum(r.total_holes_entered) as total_holes_with_putts, " +
      "  sum(r.total_zero_putts) as total_zero_putts, " +
      "  sum(r.total_one_putts) as total_one_putts, " +
      "  sum(r.total_two_putts) as total_two_putts, " +
      "  sum(r.total_three_putts) as total_three_putts, " +
      "  sum(r.total_fourormore_putts) as total_fourormore_putts, " +
      "  sum(r.total_fairways) as total_fairways, " + 
      "  sum(r.fairways_hit) as total_fairways_hit, " +
      "  max(r.max_driving_distance) as max_driving_distance, " + 
      "  sum(r.total_driving_distance) as total_driving_distance, " +
      "  sum(r.total_holes_with_driving_distance) as total_holes_with_driving_distance, " +
      "  sum(r.total_putts_gir) as total_putts_gir" +
      " from #{join} " +
      " #{where} " +
      " #{group_by} order by total_rounds desc"
    )
    
    result.collect do |r|
      RoundSummary.new(type_cast(r))
    end
  end
  
  private
  
  def type_cast(h)
    h.keys.each do |k|
      v = h[k]
      if v && k.to_s =~ /^avg_/
        h[k] = v.to_f
      elsif v
        h[k] = v.to_i
      end
    end
    return h
  end
  
  def group_by_columns
    "user_id," if @filter.users
  end
  
  def group_by
    "group by user_id" if @filter.users
  end

  def quoted_array(arr)
    arr.collect { |n| ActiveRecord::Base.connection.quote(n) }.join(",")
  end

  def conditions
    a = []
    a << "date_played between " + 
      ActiveRecord::Base.connection.quote(@filter.between[0].strftime("%Y-%m-%d")) + 
      " and " + 
      ActiveRecord::Base.connection.quote(@filter.between[1].strftime("%Y-%m-%d"))
    a << "user_id in (" + quoted_array(@filter.users) + ")" if @filter.users?
    a << "course_id=" + ActiveRecord::Base.connection.quote(@filter.course) if @filter.course?
    a << "total_holes=" + ActiveRecord::Base.connection.quote(@filter.number_of_holes) if @filter.number_of_holes?
    a << "id in (" + quoted_array(@filter.rounds) + ")" if @filter.rounds?
    a.join( " and ")  
  end
      
  def where
    "where " + conditions
  end
  
end
