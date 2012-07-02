class USGAHandicapper
  
  BONUS_FOR_EXCELLENCE = 0.96
  MAX_HANDICAP_MEN = 36.4
  MAX_HANDICAP_WOMEN = 40.4
   
  attr_accessor :rounds, :notes
  
  def initialize(rounds)
    complete, half = rounds.partition { |r| r.total_holes == 18 }

    scoring_record = complete.collect do |r|
      OpenStruct.new(
        :total_score => r.total_score,
        :date_played => r.date_played,
        :tee_rating => r.tee_rating,
        :tee_slope => r.tee_slope,
        :rounds => [r],
        :score_type => 1
      )
    end
       
    half.in_groups_of(2) do |pair|
      break if pair[1].nil?

      avg_tee_slope = if pair[0].tee_slope && pair[1].tee_slope 
        ((pair[0].tee_slope + pair[1].tee_slope) / 2).to_i
      else
        113
      end
      
      scoring_record << OpenStruct.new(
        :date_played => pair[0].date_played,
        :total_score => pair[0].total_score + pair[1].total_score,
        :tee_rating => pair[0].tee_rating + pair[1].tee_rating,
        :tee_slope => avg_tee_slope,
        :rounds => [pair[0], pair[1]],
        :score_type => 2
      )
    end
    
    @rounds = scoring_record.sort { |a,b| b.date_played <=> a.date_played }[0,20]
     
  end
  
  def best
    @best ||= @rounds.sort {|r1, r2| 
      differential(r1) <=> differential(r2)
    }[selector]
  end
  
  def differential(round)
    (((round.total_score - round.tee_rating) * 113 ) / (round.tee_slope || 113)).floor(1)
  end
  
  def selector
    case @rounds.size
      when 1..6 then 0..0
      when 7..8 then 0..1
      when 9..10 then 0..2
      when 11..12 then 0..3
      when 13..14 then 0..4
      when 15..16 then 0..5
      when 17 then 0..6
      when 18 then 0..7
      when 19 then 0..8
      else 0..9
    end
  end

  def best_average_differential
    best.inject(0) { |sum, r| sum += differential(r) } / best.size
  end
    
  def handicap(cap=true)
    if @rounds.any?
      h = (best_average_differential * 0.96).floor_to(1)
      cap ? [h, MAX_HANDICAP_MEN].min : h
    end
  end

end
