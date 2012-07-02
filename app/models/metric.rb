class Metric
  
  attr_accessor :name, :label, :options
  
  def initialize(name, label, best=0, options = {})
    @name = name
    @label = label
    @options = options
    @best = best
  end
  
  def value_formatted(*args)
    v = value(*args)
    if percentage?
      "#{v}% (#{args[0]}/#{args[1]})" unless v.nil? 
    elsif v
      v.to_s
    end
  end
  
  def value(*args)
    if percentage?
      (args[0]/(args[1]+0.0)*100).to_i if args[0] && args[1] and args[1] != 0
    elsif average? && args.length > 1
      (args[0]/(args[1]+0.0)).round_to(2) if args[0] && args[1] and args[1] != 0
    else
      args[0]
    end    
  end
  
  def self.method_missing(id, *args)
    if @metrics.has_key?(id)
      @metrics[id]
    else
      super
    end
  end
  
  def percentage?
    @name.to_s =~ /^pct_/
  end

  def average?
    @name.to_s =~ /^avg_/
  end

  def sort(vals)
    vals.select { |v| v }.sort { |a,b| a <=> b }
  end
  
  def best(vals)
    sort(vals)[@best]
  end

  def worst(vals)
    sort(vals)[(@best == 0 ? -1 : 0)]
  end
  
  def sql
    (@options[:sql] || "sum(#{@name})") + " as #{@name}"
  end
  
  def drill
    if @options.has_key?(:drill)
      Metric.get(@options[:drill][:metric])
    else
      self
    end
  end

  def filter
    if @options.has_key?(:drill)
      @options[:drill][:number_of_holes]
    end
  end
    
  def to_json
    return {
      :name => name,
      :label => label,
      :unit => percentage? ? "%" : "",
      :min => 0,
      :drill => @options[:drill]
    }.to_json
  end
  
  def self.each
    @metrics.each { |k,v| yield(k,v) }
  end
  
  def self.all
    @metrics.values
  end
  
  def self.get(id)
    @metrics[id]
  end
  
  def self.add_metric(name, label, best=0, options = {})
    @metrics ||= {}
    @metrics[name] = Metric.new(name, label, best, options)
  end
  
  add_metric(:total_rounds, "Total Rounds", -1, 
    :sql => "sum(1)", 
    :drill => false
  )
  
  add_metric(:total_holes, "Total Holes", -1)
  add_metric(:total_distance, "Total Distance", -1)
  add_metric(:total_unique_courses, "Courses", -1)
  add_metric(:total_strokes, "Total Strokes", 0, :sql => "sum(total_score)")
  add_metric(:total_score, "Total Score", 0)
  add_metric(:total_penalty, "Total Penalty", 0)
  
  add_metric(:net_score, "Net Score", 0)
  
  add_metric(:avg_18_hole_gross_score, "Average Score", 0, 
    :sql => 'truncate(avg(case total_holes when 18 then total_score else null end), 2)', 
    :drill => { :metric => :total_score, :number_of_holes => 18 } 
  )
  
  add_metric(:avg_front_9_gross_score, "Avg Front 9 Score", 0,
    :sql => "truncate(avg(case total_holes when 18 then total_front9 else null end), 2)",
    :drill => { :metric => :total_front9, :number_of_holes => 18 }
  )
  
  add_metric(:avg_back_9_gross_score, "Avg Back 9 Score", 0, 
    :sql => "truncate(avg(case total_holes when 18 then total_back9 else null end), 2)",
    :drill => { :metric => :total_back9, :number_of_holes => 18 }
  )
  
  add_metric(:total_18_hole_rounds, "Total 18 Hole Rounds", -1, :drill => false)
  
  add_metric(:avg_18_hole_net_score, "Average Score (Net)", 0, 
    :sql => "truncate(avg(case total_holes when 18 then total_score - course_handicap else null end), 2)",
    :drill => { :metric => :net_score, :number_of_holes => 18 }
  )
  
  add_metric(:avg_18_hole_total_putts, "Total Putts", 0,
    :sql => "truncate(avg(case total_holes when 18 then total_putts else null end), 2)",
    :drill => { :metric => :total_putts, :number_of_holes => 18 } 
  )
  
  add_metric(:total_front9, "Front 9 Score", 0)
  add_metric(:total_back9, "Back 9 Score", 0)
  
  add_metric(:total_9_hole_rounds, "Total 9 Hole Rounds", -1, 
    :sql => "sum(case total_holes when 9 then 1 else 0 end)", 
    :drill => false
  )
  
  add_metric(:avg_9_hole_gross_score, "Avg Score (9 Holes)", 0,
    :sql => "truncate(avg(case total_holes when 9 then total_score else null end), 2)",
    :drill => { :metric => :total_score, :number_of_holes => 9 }
  )
  
  add_metric(:avg_9_hole_total_putts, "Total Putts (9 Holes)", 0, :drill => { :metric => :total_putts, :number_of_holes => 9 })

  add_metric(:total_holes_entered, "Holes", -1, :drill => false)
  
  add_metric(:avg_par_3, "Par 3 Average", 0,
    :sql => "truncate(sum(par3_average*par3_holes)/sum(par3_holes), 2)"
  )
  
  add_metric(:avg_par_4, "Par 4 Average", 0,
    :sql => "truncate(sum(par4_average*par4_holes)/sum(par4_holes), 2)"
  )
  
  add_metric(:avg_par_5, "Par 5 Average", 0,
    :sql => "truncate(sum(par5_average*par5_holes)/sum(par5_holes), 2)"
  )
  
  add_metric(:total_ones, "Total Aces!", -1)
  add_metric(:total_eagles, "Total Eagles!", -1)
  add_metric(:total_double_eagles, "Total Dbl Eagles!", -1)
  add_metric(:total_birdies, "Total Birdies!", -1)
  add_metric(:total_pars, "Total Pars", -1)
  add_metric(:total_bogeys, "Total Bogeys", 0)
  add_metric(:total_dbl_bogeys, "Total Dbl Bogeys", 0)
  add_metric(:total_others, "Total Other", 0)  
  add_metric(:pct_birdies, "Birdie %", -1)
  add_metric(:pct_pars, "Par %", -1)
  add_metric(:pct_bogeys, "Bogey %", 0)
  add_metric(:pct_dbl_bogeys, "Dbl Bogey %", 0)
  add_metric(:pct_others, "Other %", 0)

  add_metric(:total_holes_with_putts, "Holes", -1, 
    :sql => "Sum(total_holes_entered)",
    :drill => false
  )
  
  add_metric(:avg_putts_per_hole, "Avg Putts Per-hole", 0,
    :sql => "truncate(sum(putting_average*total_holes_entered)/sum(total_holes_entered), 2)"
  )
  
  add_metric(:avg_putts_per_hole_after_gir, "Avg Putts Per-hole (GIR)", 0)
  
  add_metric(:total_putts, "Total Putts", 0)
  add_metric(:total_putts_gir, "Total Putts (GIR)", 0)
  add_metric(:total_zero_putts, "No Putts", -1)  
  add_metric(:total_one_putts, "One Putts", -1)            
  add_metric(:total_two_putts, "Two Putts", -1) 
  add_metric(:total_three_putts, "Three Putts", 0) 
  add_metric(:total_fourormore_putts, "Doh!", 0) 
  add_metric(:pct_one_putts, "One Putt %", -1)
  add_metric(:pct_two_putts, "Two Putt %", -1)
  add_metric(:pct_three_putts, "Three Putt %", 0)
  add_metric(:pct_fourormore_putts, "Doh! %", 0)

  add_metric(:total_girs, "GIRs", -1)
  add_metric(:pct_girs, "GIR %", -1)
  add_metric(:total_fairways, "Fairways", -1)
  add_metric(:total_fairways_hit, "Fairways Hit", -1, :sql => "sum(fairways_hit)")
  add_metric(:pct_fairways_hit, "Fairways Hit %", -1)
  add_metric(:avg_driving_distance, "Avg Driving Distance", -1)
  
  add_metric(:max_driving_distance, "Longest Drive", -1,
    :sql => "max(max_driving_distance)"
  )
  
  add_metric(:total_driving_distance, "Total Driving Distance", -1)
  add_metric(:total_holes_with_driving_distance, "Total Holes with Driving Distance", -1)
  
#  protected
#    
#  def map_to_source(source, field_name)
#    if SOURCES.has_key?(source.class)
#      return SOURCES[source.class][field_name] || field_name
#    end
#    return field_name
#  end
end

