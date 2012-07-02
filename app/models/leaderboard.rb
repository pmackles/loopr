class Leaderboard 
  attr_reader :leaders, :title, :subtitle, :stat
  attr_writer :leaders, :title, :subtitle, :stat
  
  def initialize(leaders)
    @leaders = leaders
  end
end
