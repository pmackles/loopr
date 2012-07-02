module ScorecardHelper
  def css_style_for_score (score)

    return "" if score.nil? || score.score.nil?

    case score.over_under_par
      when -20..-2: "eagle"
      when -1: "birdie"
      when 1: "bogey"
      when 2..50: "double-bogey"
    end

  end
  
  def tee_box(tee)
    content_tag :span, "&nbsp;&nbsp;&nbsp;&nbsp;", :class => "tee #{tee.color}"
  end  

  def tee_shot(score)
	 tee_shot_club = score.tee_shot_club || "-"
	 distance = score.tee_shot_distance || "-"
	 if score.fairway.nil?
	   direction = "none"
	   tooltip = ""
	 else
	   direction = score.fairway.to_s
	   tooltip = Score::DIRECTIONS.find() { |d| d.last == score.fairway }.first
	 end
	 
	 "#{tee_shot_club}<br />#{image_tag('fairway-arrow-' + direction + '.gif', :alt => '', :title => tooltip)}<br />#{distance}"
  end

end
