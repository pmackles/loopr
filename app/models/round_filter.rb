class RoundFilter

#  TIME_PERIODS = [["Lifetime", "max"], ["Last year", "1y"], ["Last 6 months", "6m"], ["Last 3 months", "3m"], ["Last month", "1m"]]
  NUMBER_OF_HOLES = [["All", ""], ["18 Holes", "18"], ["9 Holes", "9"]]
  
  attr_accessor :time_period, :course, :number_of_holes, :users, :rounds
  
  def initialize(params)
    @time_period = RoundFilter.time_periods.collect { |y| y.last }.find { |y| y.to_s == params[:time_period] } || 0  
    @course = params[:course]
    @number_of_holes = %w(9 18).find { |t| t == params[:number_of_holes] } || ""
    @users = make_array(params[:users])
    @rounds = make_array(params[:rounds])
  end

  def from
    case @time_period
      when "1y" then Time.now.months_ago(12)
      when "6m" then Time.now.months_ago(6)
      when "3m" then Time.now.months_ago(3)
      when "1m" then Time.now.months_ago(1)
      else Date.new(1950, 1, 1)
    end
  end

  def between
    if @time_period == 0
      from = Date.new(1950, 1, 1)
      return [from, Time.now.months_since(12)]
    else
      from = Date.new(@time_period, 1,1)
      return [from, from >> 12]
    end
  end
  
  def self.time_periods
    now = Time.now
    tp = []
    tp << ["Lifetime", 0]
    (0..4).each do |year|
      dt = now.years_ago(year)
      tp << ["#{dt.year}", dt.year]
    end
    tp
  end
  
  def limit?
    @time_period == "last20"
  end
  
  def course?
    @course.blank? == false
  end
  
  def number_of_holes?
    @number_of_holes.blank? == false
  end
  
  def rounds?
    @rounds.blank? == false
  end
    
  def users?
    @users.blank? == false
  end
  
  private
  
  def make_array(i)
    if i.is_a?(Array)
      return i
    elsif !i.blank?
      return i.split(",")
    end
  end
  
end
