module RoundHelper
  def round_headline(round, options = {})
    options[:show_user] = false unless options.has_key?(:show_user)
    options[:show_course] = true unless options.has_key?(:show_course)
    render(:partial => 'round/round', :object => round, :locals => options)
  end
  
  def score_type(round)
    case round.score_type
      when 2 : "Front 9"
      when 3 : "Back 9"
    else
      "18"
    end
  end
  
end
