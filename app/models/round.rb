class Round < ActiveRecord::Base
  
  include StatableX

  metric :total_score
  metric :total_front9
  metric :total_back9
  
  metric :net_score
  metric :total_holes_entered
  metric :avg_par_3, :from => [:par3_average]
  metric :avg_par_4, :from => [:par4_average]
  metric :avg_par_5, :from => [:par5_average]
  metric :total_ones
  metric :total_eagles
  metric :total_double_eagles
  metric :total_birdies
  metric :total_pars
  metric :total_bogeys
  metric :total_dbl_bogeys
  metric :total_others
  
  metric :pct_birdies, :from => [:total_birdies, :total_holes_entered]
  metric :pct_pars, :from => [:total_pars, :total_holes_entered]
  metric :pct_bogeys, :from => [:total_bogeys, :total_holes_entered]
  metric :pct_dbl_bogeys, :from => [:total_dbl_bogeys, :total_holes_entered]
  metric :pct_others, :from => [:total_others, :total_holes_entered]
  
  metric :total_holes_with_putts, :from => [:total_holes_entered]
  metric :avg_putts_per_hole, :from => [:putting_average]
  metric :avg_putts_per_hole_after_gir, :from => [:total_putts_gir, :total_girs]
  metric :total_putts
  
  metric :total_zero_putts
  metric :total_one_putts
  metric :total_two_putts
  metric :total_three_putts
  metric :total_fourormore_putts
  metric :pct_one_putts, :from => [:total_one_putts, :total_holes_entered]
  metric :pct_two_putts, :from => [:total_two_putts, :total_holes_entered]
  metric :pct_three_putts, :from => [:total_three_putts, :total_holes_entered]
  metric :pct_fourormore_putts, :from => [:total_fourormore_putts, :total_holes_entered]

  metric :total_girs
  metric :pct_girs, :from => [:total_girs, :total_holes_entered]
  metric :total_fairways
  metric :total_fairways_hit, :from => [:fairways_hit]
  metric :pct_fairways_hit, :from => [:fairways_hit, :total_fairways]
  metric :avg_driving_distance, :from => [:total_driving_distance, :total_holes_with_driving_distance]
  metric :max_driving_distance
  
  belongs_to :user
  belongs_to :course

#  has_many :outings, :finder_sql =>
#      'SELECT o.* ' +
#      'FROM outings o, memberships m ' +
#      'WHERE o.date = "#{self.date_played}" AND o.course_id = #{self.course_id} ' +
#      'AND o.group_id=m.group_id and m.user_id=#{self.user.id}'
  
#  validates_presence_of :total_score, :message => "required", :if => :simple?

#  validates_inclusion_of :total_score, 
#          :in=>59..180, 
#          :allow_nil => true,
#          :message => "scores must be between 55 and 120", 
#          :if => :simple?

  validates_date :date_played, :message => "invalid date", 
                 :before => Proc.new { 2.day.from_now.to_date }, 
                 :before_message => "can't be in the future"

  validates_presence_of :course, :message => 'required. You must have played somewhere??'

  validates_presence_of :tee_name, :message => 'required. Usually a color like red, blue, yellow will do.'
       
  validates_inclusion_of :tee_yardage, :in => 500..9000, :allow_nil => true,
                         :message => 'should be a number between 500 and 9000'

  before_save :summarize_scores, :calculate_differential
  
  def self.per_page
    15
  end
    
  def tee
    return Tee.new(
      :mens_rating => tee_rating, 
      :mens_slope => tee_slope, 
      :name => tee_name, 
      :yardage => tee_yardage)
  end
  
  def blank_scores
    Array.new(18) { |i|
      score = Score.new
      unless simple?
        score.penalty_strokes = 0
        score.putts = 2
      end
      score.hole = i
      score.round = self
      score
    }
  end

  def scorecard
    sc = Scorecard.new
    sc.course = self.course
    sc.rounds = [self]
#    sc.show = ['score', 'putts', 'penalty', 'gir', 'holes']
#    sc.show_name = false
    sc.date = self.date_played
    sc
  end
    
  def validate

    if count_towards_handicap == 1
      if tee_rating.blank?
        errors.add(:tee_rating, 'required to calculate handicap (should be on you scorecard)')
      else
        errors.add(:tee_rating, 'should be a number between 10 and 100') unless (10..100).include?(tee_rating)
      end
      
      if tee_slope.blank?
        if @course && @course.has_slope
          errors.add(:tee_slope, 'required to calculate handicap (should be on you scorecard)')
        end
      else
        if @course && @course.has_slope
          errors.add(:tee_slope, 'should be a number between 50 and 180') unless (50..180).include?(tee_slope)
        else
          errors.add(:tee_slope, 'can be left blank if your course doesn\'t have a slope rating') unless (50..180).include?(tee_slope)
        end
      end
      
    end
               
    if detailed?
      scoresValid = true
      scores[holes_entered].each { |s|
        s.errors.add(:score, "invalid") unless (1..22).include?(s.score)
        s.errors.add(:par, "invalid") unless (3..5).include?(s.par)
        s.errors.add(:putts, "invalid") unless (0..9).include?(s.putts)
        s.errors.add(:penalty_strokes, "invalid") unless (0..9).include?(s.penalty_strokes)
        
        scoresValid = false unless s.errors.empty?
      }
  
      unless scoresValid
        errors.add_to_base(
          "To record a detailed score, we'll need to know your total score for the hole as well as " +
          "par, total putts and penalty strokes."
        )
      end
    else
      logger.debug("calling simple validation")
      errors.add(:total_score, "required and must be a number.") unless (1..180).include?(read_attribute(:total_score))
    end
    
  end
    
  def save!
    super
    if detailed?
      scores.each { |s|
        unless holes_entered.include?(s.hole)
          s.reset
        end
        
        s.save 
      }
    else
      Score.delete_all("round_id=#{self.id}")
    end
  end
 
  def scores
    unless @scores
      if new_record?
        @scores = blank_scores
      else
        @scores = Score.find(:all, 
                             :conditions => "round_id=#{self.id}", 
                             :order => 'hole')
        if @scores.empty?
          @scores = blank_scores
        end   
      end
    end
    @scores
  end
     
  def summarize_scores
    logger.debug("begin summarize_scores")
    averages = {"3" => 0.0, "4" => 0.0, "5" => 0.0, "all" => 0.0}
    counts = {"3" => 0, "4" => 0, "5" => 0, "all" => 0}
    putting_averages = {"3" => 0.0, "4" => 0.0, "5" => 0.0}
    putting_counts = {"3" => 0, "4" => 0, "5" => 0}
    zero_putts = {"3" => 0, "4" => 0, "5" => 0}
    one_putts = {"3" => 0, "4" => 0, "5" => 0}
    two_putts = {"3" => 0, "4" => 0, "5" => 0}
    three_putts = {"3" => 0, "4" => 0, "5" => 0}
    fourormore_putts = {"3" => 0, "4" => 0, "5" => 0}
    ones = {"3" => 0, "4" => 0, "5" => 0}
    eagles = {"3" => 0, "4" => 0, "5" => 0}
    double_eagles = {"3" => 0, "4" => 0, "5" => 0}
    birdies = {"3" => 0, "4" => 0, "5" => 0}
    pars = {"3" => 0, "4" => 0, "5" => 0}
    bogeys = {"3" => 0, "4" => 0, "5" => 0}
    others = {"3" => 0, "4" => 0, "5" => 0}
    dbl_bogeys = {"3" => 0, "4" => 0, "5" => 0}
    girs = {"3" => 0, "4" => 0, "5" => 0}
    penalty = {"3" => 0, "4" => 0, "5" => 0}
    
    reset_details
    
    self.total_holes = nine_holes? ? 9 : 18
        
    if detailed?
      total_eagles = total_birdies = total_pars = total_double_eagles = 0
      total_bogeys = total_ones = total_others = total_dbl_bogeys = 0
      scores_with_putts = 0
      total_fairways = fairways_hit = 0
      max_driving_distance = -1
      total_driving_distance = 0
      total_holes_with_driving_distance = 0
      self.total_score = nil
      total_putts_gir = 0
      
      for score in self.scores
        next unless holes_entered.include?(score.hole)

        averages[score.par.to_s] += score.score
        averages["all"] += score.score
        
        counts[score.par.to_s] += 1
        counts["all"] += 1

        girs[score.par.to_s] += 1 if score.gir?
        
        penalty[score.par.to_s] += score.penalty_strokes if score.penalty_strokes

        if score.putts
          scores_with_putts += 1
          case score.putts
            when 0 : zero_putts[score.par.to_s] += 1
            when 1 : one_putts[score.par.to_s] += 1
            when 2 : two_putts[score.par.to_s] += 1
            when 3 : three_putts[score.par.to_s] += 1
            else fourormore_putts[score.par.to_s] += 1
          end

          putting_averages[score.par.to_s] += score.putts
          putting_counts[score.par.to_s] += 1
          total_putts_gir += score.putts if score.gir?
        end
        
        if score.score == 1
          total_ones += 1; ones[score.par.to_s] += 1
        else
          case score.over_under_par
            when Score::DOUBLE_EAGLE : total_double_eagles += 1; double_eagles[score.par.to_s] += 1
            when Score::EAGLE : total_eagles += 1; eagles[score.par.to_s] += 1
            when Score::BIRDIE : total_birdies += 1; birdies[score.par.to_s] +=1
            when Score::PAR : total_pars += 1; pars[score.par.to_s] +=1
            when Score::BOGEY: total_bogeys += 1; bogeys[score.par.to_s] +=1
            when Score::DBL_BOGEY: total_dbl_bogeys += 1; dbl_bogeys[score.par.to_s] +=1
            else total_others += 1; others[score.par.to_s] +=1
          end
        end
                  
        total_fairways += 1 if score.fairway?
        fairways_hit += 1 if score.fairway_hit?
        
        if score.driver? && score.tee_shot_distance?
          total_driving_distance += score.tee_shot_distance 
          total_holes_with_driving_distance += 1
          max_driving_distance = score.tee_shot_distance if score.tee_shot_distance > max_driving_distance
        end
      end

      self.par3_holes = counts["3"]
      self.par4_holes = counts["4"]
      self.par5_holes = counts["5"]    

      self.total_score = total_score
      self.total_front9 = total_score(0..8)
      self.total_back9 = total_score(9..17)
      self.total_ones = total_ones
      self.total_double_eagles = total_double_eagles
      self.total_eagles = total_eagles
      self.total_birdies = total_birdies
      self.total_pars = total_pars
      self.total_bogeys = total_bogeys
      self.total_dbl_bogeys = total_dbl_bogeys
      self.total_others = total_others

      self.total_putts = total_putts
      self.putting_average = putting_average
      self.total_girs = total_girs
      
      self.total_penalty = total_penalty
      self.total_holes = total_holes
      self.total_holes_entered = total_holes_entered
      
      self.total_fairways = total_fairways unless total_fairways == 0
      self.fairways_hit = fairways_hit  unless total_fairways == 0
      self.max_driving_distance = max_driving_distance unless  total_holes_with_driving_distance == 0
      self.total_driving_distance = total_driving_distance unless total_holes_with_driving_distance == 0
      self.total_holes_with_driving_distance = total_holes_with_driving_distance unless total_holes_with_driving_distance == 0
      self.total_putts_gir = total_putts_gir
      
      ["3", "4", "5"].each do |p|
        if counts[p] > 0
          write_attribute("par#{p}_average", (averages[p] / counts[p]))
          write_attribute("par#{p}_putting_average", (putting_averages[p] / putting_counts[p]))
          write_attribute("par#{p}_zero_putts", zero_putts[p])
          write_attribute("par#{p}_one_putts", one_putts[p])
          write_attribute("par#{p}_two_putts", two_putts[p])
          write_attribute("par#{p}_three_putts", three_putts[p])
          write_attribute("par#{p}_fourormore_putts", fourormore_putts[p])
          write_attribute("par#{p}_ones", ones[p])
          write_attribute("par#{p}_eagles", eagles[p])
          write_attribute("par#{p}_double_eagles", double_eagles[p])
          write_attribute("par#{p}_birdies", birdies[p])
          write_attribute("par#{p}_pars", pars[p])
          write_attribute("par#{p}_bogeys", bogeys[p])
          write_attribute("par#{p}_dbl_bogeys", dbl_bogeys[p])
          write_attribute("par#{p}_others", others[p])
          write_attribute("par#{p}_girs", girs[p])
          write_attribute("par#{p}_penalty", penalty[p])
        else
          write_attribute("par#{p}_average", nil)
          write_attribute("par#{p}_putting_average", nil)
          write_attribute("par#{p}_zero_putts", nil)
          write_attribute("par#{p}_one_putts", nil)
          write_attribute("par#{p}_two_putts", nil)
          write_attribute("par#{p}_three_putts", nil)
          write_attribute("par#{p}_fourormore_putts", nil)
          write_attribute("par#{p}_ones", nil)
          write_attribute("par#{p}_eagles", nil)
          write_attribute("par#{p}_double_eagles", nil)
          write_attribute("par#{p}_birdies", nil)
          write_attribute("par#{p}_pars", nil)
          write_attribute("par#{p}_bogeys", nil)
          write_attribute("par#{p}_others", nil)
          write_attribute("par#{p}_girs", nil)
          write_attribute("par#{p}_penalty", nil)
        end
      end
  
      self.total_zero_putts = zero_putts["3"] + zero_putts["4"] + zero_putts["5"]
      self.total_one_putts = one_putts["3"] + one_putts["4"] + one_putts["5"]
      self.total_two_putts = two_putts["3"] + two_putts["4"] + two_putts["5"]
      self.total_three_putts = three_putts["3"] + three_putts["4"] + three_putts["5"]
      self.total_fourormore_putts = fourormore_putts["3"] + fourormore_putts["4"] + fourormore_putts["5"]
           
      self.par_average = (averages["all"] / counts["all"])

    end
  end
  
  def calculate_differential   
    if count_towards_handicap == 1 && handicap && (score_type == 0 || score_type == 1)
      self.differential = self.total_score - tee_rating
      self.differential = (self.differential * 113 ) / tee_slope if tee_slope
      self.course_handicap = ((handicap * (tee_slope || 113))/113).round.to_i
    else
      self.differential = nil
      self.course_handicap = nil
    end
    
  end
  
  def authorized?(user)
    (self.user == user)
  end

  def putting_average  
    tp = total_putts
    return (tp / ((total_holes)+0.0)).round_to(2) unless tp.nil?
  end
  
  def detailed?
    details == 1
  end

  def simple?
    details == 0
  end
  
  def nine_holes?
    score_type == 2 || score_type == 3
  end

  def net_score
    if count_towards_handicap == 1 && course_handicap && total_holes == 18
      total_score - course_handicap
    end
  end
  
  def total_score(range = nil)
    range = holes_entered unless range

    if simple? && (range.nil? || range == (0..17))
      return read_attribute(:total_score)
    elsif read_attribute(:total_score) && (range.nil? || range == (0..17))
      return read_attribute(:total_score)
    elsif read_attribute(:total_front9) && range == (0..8)
      return read_attribute(:total_front9)
    elsif read_attribute(:total_back9) && range == (9..17)
      return read_attribute(:total_back9)
    end
    
    total = 0 
    scores[range].each { |s|
      if s.score && !total.nil?
        total += s.score
      end
    }
    total
  end
    
  def total_putts(range = nil)
    unless simple?
      if read_attribute(:total_putts) && (range.nil? || range == (0..17))
        return read_attribute(:total_putts)
      end
      range = holes_entered unless range
      total = 0 
      self.scores[range].each { |s|
        if s.putts && !total.nil?
          total += s.putts
        end
      }
      total
    end
  end

  def total_girs(range = nil)
    unless simple?
      if read_attribute(:total_girs) && (range.nil? || range == (0..17))
        return read_attribute(:total_girs)
      end
      
      range = holes_entered unless range
      total = 0 
      self.scores[range].each { |s| 
        if total
          case s.gir?
            when true: total += 1
#            when nil: total = nil
          end   
        end
      }
      total
    end
  end
  
  def total_penalty(range = nil)
    unless simple?
      range = holes_entered unless range
      total = 0 
      self.scores[range].each { |s| 
        if s.penalty_strokes && !total.nil?
          total += s.penalty_strokes 
#       else
#          total = nil
        end
      }
      total
    end
  end

  def holes_entered
    if detailed?
      case score_type
        when 0: 0..17
        when 2: 0..8
        when 3: 9..17
      end
    end
  end

  def total_holes_entered
   (holes_entered.last - holes_entered.first) + 1 unless holes_entered.nil?
  end

  def before_destroy
    Score.delete_all "round_id=#{self.id}"    
  end
  
  def to_json
    return {
        :id => id,
        :date_played => date_played.to_formatted_s(:mmddyy),
        :course => course.name,
        :stats => Round.metrics.collect { |m| m.name }.to_h { |n| { :value => send(n), :value_formatted => send(n.to_s + "_formatted" ) } },
        :details => details,
        :total_holes => total_holes 
    }.to_json
  end
  
  def self.reload
    Round.find(:all).each { |r| r.save }
  end
  
  def self.blank
    r = Round.new
    r.total_score = nil
    r.scores.each do |s|
      s.putts = nil
    end
    r
  end
  
  def self.list(options = {})
    joins = " "
    unless options.has_key?(:conditions)
      joins += "use index(rounds_created_on) "
    end
    joins += " inner join courses c on (rounds.course_id=c.id) inner join users u on (rounds.user_id=u.id)"
    
    find(:all, options.reverse_merge({
      :select => "rounds.*, c.name as course_name, u.login as user_login, u.icon_url as user_icon_url, u.source as user_source, u.facebook_name as user_facebook_name, u.facebook_id as user_facebook_id", 
      :joins => joins, 
      :limit => 20, 
      :conditions => "1=1", 
      :order => "created_on desc"
    }))
  end
  
#  def self.find_all_by_user_id(user_id, options = {})
#    Round.find(:all, 
#      :include => [:course, :user], 
#      :order => options[:order] || 'date_played desc', 
#      :conditions => ['rounds.user_id in (?)', user_id],
#      :limit => (options[:limit] || 100),
#      :offset => (options[:offset] || 0)
#    )
#  end
  
  private
  
  def reset_details
    self.total_putts = nil
    self.total_front9 = nil
    self.total_back9 = nil
    self.par3_average = nil
    self.par4_average = nil
    self.par5_average = nil
    self.total_ones = nil
    self.total_double_eagles = nil
    self.total_eagles = nil
    self.total_birdies = nil
    self.total_pars = nil
    self.total_bogeys = nil
    self.total_dbl_bogeys = nil
    self.total_others = nil
    self.total_girs = nil
    self.total_penalty = nil
    self.total_holes = nil
    self.total_zero_putts = nil
    self.total_one_putts = nil
    self.total_two_putts = nil
    self.total_three_putts = nil
    self.total_fourormore_putts = nil
    self.putting_average = nil
    self.par_average = nil
    self.total_holes_entered = nil
    self.total_fairways = nil
    self.fairways_hit = nil
    self.max_driving_distance = nil
    self.total_driving_distance = nil
    self.total_holes_with_driving_distance = nil
    self.total_putts_gir = nil
    
    %w(par5 par4 par3).each do |p|
      write_attribute("#{p}_zero_putts", nil)
      write_attribute("#{p}_one_putts", nil)
      write_attribute("#{p}_two_putts", nil)  
      write_attribute("#{p}_three_putts", nil)  
      write_attribute("#{p}_fourormore_putts", nil)  
      write_attribute("#{p}_penalty", nil)
      write_attribute("#{p}_putting_average", nil)
      write_attribute("#{p}_eagles", nil)
      write_attribute("#{p}_double_eagles", nil)
      write_attribute("#{p}_birdies", nil)
      write_attribute("#{p}_bogeys", nil)
      write_attribute("#{p}_dbl_bogeys", nil)
      write_attribute("#{p}_pars", nil)
      write_attribute("#{p}_ones", nil)
      write_attribute("#{p}_others", nil)
      write_attribute("#{p}_girs", nil)
      write_attribute("#{p}_holes", nil)
    end
  end
  
end
