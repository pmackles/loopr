
class StatSorter
  attr_accessor :statables
  
  def initialize(statables)
    @statables = statables
  end
  
  def best(metric)
    b = metric.best(@statables.collect { |s| s.last.send(metric.name) })
    @statables.select do |s| 
      s.last.send(metric.name) == b
    end
  end
end

