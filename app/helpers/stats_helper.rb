module StatsHelper

  def sparkline_img(data)
    data_without_nils = data.reject { |d| d.blank? }
#    if data_without_nils.length > 1
      options = {}
      options[:cht] = "ls"
      options[:chs] = "40x15"
      options[:chd] = "t:#{data_without_nils.join(",")}"
      options[:chds] = "#{data_without_nils.min.to_i - 1},#{data_without_nils.max.to_i + 1}"
      "<img src=\"http://chart.apis.google.com/chart?" + options.collect { |k,v| "#{k}=#{v}" }.join("&") + "\" />"
#    end
  end
  
#  TRANSITIONS = %w{ spin scale zoom slide_right slide_left slide_up slide_down }
#  COLORS = ["#058DC7", "#50B432", "#ED561B", "#EDEF00"]
#  
#  def f_pct(got, total)
#  	if got && total > 0
#  		"#{f((got / (total + 0.0)).round_to(2))} (#{got}/#{total})"
#  	else
#  		na
#  	end
#  end
  
#  def trend_indicator(c, s1, s2)
#    if StatSummary::STATS[c][:order] == 1 
#	 if s1.compare(c, s2) == -1 
#	   image_tag "darr_green.gif"
#	 elsif s1.compare(c, s2) == 1 
#	   image_tag "uarr_red.gif" 
#     else 
#	   image_tag "yellow_bar.gif" 
#     end 
#	elsif StatSummary::STATS[c][:order] == 0 
#	 if s1.compare(c, s2) == -1 
#	   image_tag "uarr_green.gif"
#	 elsif s1.compare(c, s2) == 1 
#      image_tag "darr_red.gif" 
#	 else 
#      image_tag "yellow_bar.gif"
#     end 						
#    end
#  end
  
#  def stat_label(stat)
#    case stat
#    when "gir_percentage" then "GIR %"
#    when "fairways_hit_percentage" then "Fairways Hit %"
#    when "putting_average_after_gir" then "Putting Avg after GIR"
#    else
#      stat.humanize
#    end
#  end
#  
#  def random_transition
#    TRANSITIONS[rand(TRANSITIONS.size)]
#  end
  
#  def total_and_percent(total, percent)
#    percent ? "#{f total} (#{f percent})" : "#{f total}"
#  end
#  
#  def minichart(data, chartheight = 20.0, onclick = nil)
#    max = data.max { |a,b| (a || -1) <=> (b || -1) }
#    markup = Builder::XmlMarkup.new
#    markup.div(:class => 'minichart') do 
#      data.each_with_index { |d, i| 
#        barheight = (d || 0) * ((max && max > 0) ? (chartheight / max) : 1)
#        markup.div("", :style => "left: #{(i * 4)}px; top: #{(chartheight - barheight).round}px; height: #{barheight.round}px;")
#      }
#    end
#  end
  
#  def relevant_stats(round)
#  	return [
#  		["Per Hole Stats", nil],
#  		["Holes", :f_total_holes_entered], 
#  	  ["GIR", :f_gir_percentage], 
#  	  ["Putting Avg", :f_putting_average],
#  	  ["Putting Avg after GIR", :f_putting_average_after_gir],
#  	  ["Par 3 Average", :f_par3_average],
#  	  ["Par 4 Average", :f_par4_average],
#  	  ["Par 5 Average", :f_par5_average],
#  	  ["Fairways Hit", :f_fairways_hit_percentage],
#  	  ["Longest Drive", :f_longest_tee_shot_distance],
#  	  ["Average Drive", :f_average_drive],
#    ]
#  
##  	simple_round_stats = [
##  	  ["Per Round Stats", nil],
##  		["Gross Score", :f_scoring_average],
##  		["Net Score", :f_net_score],
##  	]
#  	
##  	detailed_round_stats = [
##  		["Front 9", :f_front9_average],
## 		["Back 9", :f_back9_average],
##  		["Total Putts", :f_total_putts_average],
##    ]
#    
##    return case round.score_type
##    	when 0 : detailed_hole_stats
##    	when 1 : simple_round_stats
##    	else detailed_hole_stats
##   	end
#  end

#  def f_gross_score(statable)
#    f statable.scoring_average
#  end
#
#  def f_net_score(statable)
#    f statable.net_score
#  end
#  
#  def f_one_putt_percentage(statable)
#    "#{f statable.one_putt_percentage} (#{statable.total_one_putts}/#{statable.total_holes_entered})"
#  end
#
#  def f_two_putt_percentage(statable)
#    "#{f statable.two_putt_percentage} (#{statable.total_two_putts}/#{statable.total_holes_entered})"
#  end
#
#  def f_three_putt_percentage(statable)
#    "#{f statable.three_putt_percentage} (#{statable.total_three_putts}/#{statable.total_holes_entered})"
#  end
#        
#  def f_total_holes_entered(statable)
#    f statable.total_holes_entered
#  end
#
#  def f_putting_average(statable)
#    f statable.putting_average
#  end
#
#  def f_putting_average_after_gir(statable)
#    f statable.putting_average_after_gir
#  end
#  
#  def f_par3_average(statable)
#    f statable.par3_average
#  end
#
#  def f_par4_average(statable)
#    f statable.par4_average
#  end
#
#  def f_par5_average(statable)
#    f statable.par5_average
#  end
#
#  def f_longest_tee_shot_distance(statable)
#    f statable.longest_tee_shot_distance
#  end
#
#  def f_average_drive(statable)
#    f statable.average_drive
#  end
#
#  def f_scoring_average(statable)
#    f statable.scoring_average
#  end
#
#  def f_net_score(statable)
#    f statable.net_score
#  end
#
#  def f_front9_average(statable)
#    f statable.front9_average
#  end
#
#  def f_back9_average(statable)
#    f statable.back9_average
#  end
#
#  def f_total_putts_average(statable)
#    f statable.total_putts_average
#  end
#
#  def f_par3_gir_percentage(statable)
#    if statable.par3_gir_percentage
#      "#{f statable.par3_gir_percentage} (#{statable.par3_girs}/#{statable.par3_holes})"
#    else
#      na
#    end
#  end
#
#  def f_par4_gir_percentage(statable)
#    "#{f statable.par4_gir_percentage} (#{statable.par4_girs}/#{statable.par4_holes})"
#  end
#
#  def f_par5_gir_percentage(statable)
#    "#{f statable.par5_gir_percentage} (#{statable.par5_girs}/#{statable.par5_holes})"
#  end
#          
#  def f_gir_percentage(statable)
#    if statable.gir_percentage
#      "#{f statable.gir_percentage} (#{statable.total_girs}/#{statable.total_holes_entered})"
#    else
#      na
#    end
#  end
#
#  def f_fairways_hit_percentage(statable)
#    if statable.fairways_hit_percentage
#      "#{f statable.fairways_hit_percentage} (#{statable.fairways_hit}/#{statable.total_fairways})"
#    else
#      na
#    end
#  end
    
#  def h_barchart(title, labels, data, colors, data_labels = [], max = nil, chartwidth = 160, onclick = nil)
#    max = data.max { |a,b| (a || -1) <=> (b || -1) } unless max
#    markup = Builder::XmlMarkup.new
#  	markup << title
#    markup.table(:class => "bar-chart") do 
#      data.each_with_index do |d, i|
#      	markup.tr() do
#        	barwidth = (d || 0) * ((max && max > 0.0) ? (chartwidth / max) : 1)
#        	markup.td(:class => "chart" + (i == 0 ? " first" : (i == data.length - 1 ? " last" : ""))) do
#						markup.div("", :class => :bar, :style => "width: #{barwidth.to_i}px; background-color: #{colors[i]}")
#					end
#        	markup.td(:class => "label") do
#        		markup << (data_labels[i] || f(d))
#        	end
#      	end
#      end
#    end
#  end
end
