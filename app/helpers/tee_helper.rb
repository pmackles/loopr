module TeeHelper
  def score_type(tee)
    case tee.score_type
      when 2 : "Front 9"
      when 3 : "Back 9"
    else
      "18"
    end
  end
  
  def score_types
    [["18", 0], ["Front 9", 2], ["Back 9", 3]]
  end
end
