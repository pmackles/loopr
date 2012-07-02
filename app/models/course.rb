

class Course < ActiveRecord::Base

  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude

  before_create :geocode_address

  validates_presence_of :name, :message => "required"
  validates_presence_of :state, :message => 'required', :if => :has_subdivisions?
  validates_presence_of :country, :message => 'required'
  validates_presence_of :city, :message => "required"

  
  validates_format_of :url, 
    :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, 
    :message => "invalid", :if => :url?
 
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
#  has_and_belongs_to_many :users

  has_many :tees, :order => 'yardage desc', :dependent => :delete_all
  
  has_many :tips, :dependent => :delete_all do
    def top(limit = 3)
      @top_tips ||= find(:all, :order => 'created_at desc', :limit => limit)
    end
  end
    
  has_many :holes, :order => "number asc", :dependent => :delete_all
  
#  has_many :rounds, :order => "date_played desc" do
#    def last(limit)
#      find(:all, :limit => limit)
#    end
#  end 
  
  has_many :saved_courses, :include => :user, :order => 'users.login' do
    def of_type(save_type)
      find(:all, :conditions => ['save_type=?', save_type])
    end
  end

  has_one :stats, :class_name => "CourseStatSummary", :foreign_key => "entity_id", :dependent => :delete
  
#  has_many :reviews,
#        :class_name => "CourseReview",
#        :foreign_key => "type_id",
#        :order => "created_at desc",
#        :dependent => :delete_all,
#        :conditions => "status = 0" do
#    def top(limit = 3)
#      @top_reviews ||= find(:all, :order => 'created_at desc', :limit => limit)
#    end
#    
#    def page(limit = 10, offset = 0)
#      find(:all, :order => 'created_at desc', :limit => limit, :offset => offset)
#    end
#    
#  end
  
  composed_of :address,
              :mapping => [%w(street street), 
                           %w(city city), 
                           %w(state state), 
                           %w(country country), 
                           %w(postal_code postal_code),
                           %w(phone phone)]
  INCOMPLETE = 0
  COMPLETE = 1
  COMPLETE_WITH_TEES = 2
  
  STATUS = {
    "Incomplete" => INCOMPLETE,
    "Complete" => COMPLETE,
    "Complete w/ Tees" => COMPLETE_WITH_TEES,
  }
  
  CLUB_TYPES = {
    "Public" => 0, 
    "Resort" => 1, 
    "Private" => 2, 
    "Semi-Private" => 3, 
    "Military" => 4
  }
  
  FEE_RANGES = {
    "Under $20" => 0, 
    "Between $20 - $49" => 1, 
    "Between $50 - $79" => 2, 
    "Between $80 - $124" => 3, 
    "$125 and up" => 4
  }

  FEE_RANGES2 = {
    "Under $20" => 0, 
    "Under $50" => 1, 
    "Under $80" => 2, 
    "Under $125" => 3, 
  }
    
  DISTANCES = ["5", "15", "25", "50", "75"]

  def self.per_page
    15
  end
  
#  def created_by
#    return @created_by unless @created_by.nil?
#    if read_attribute(:created_by)
#      @created_by = User.find(read_attribute(:created_by))
#    end    
#  end

  def before_validation
    self.url = "http://#{url}" unless url.blank? || url.match(/http:\/\//)
  end
  
  def has_subdivisions?
    Geography::SUBDIVISIONS[country] && Geography::SUBDIVISIONS[country].any?
  end
  
  def has_slope
    %w(US CA).include?(country)
  end

  def length_units
    %w(US CA GB MX BM MY AG BB IN AW PH VN TC).include?(country) ? "yards" : "meters"
  end
    
  def rating_system
    "Rating"
#    case country
#      when "GB": "SSS"
#      when "AU": "ACR"
#      else "Rating"
#    end
  end
  
  def self.top_cities(country_code, subdivision_code)
    connection.select_values("select city,count(1) cnt from courses where country='#{country_code}' and state='#{subdivision_code}' group by city order by cnt desc limit 25").sort
  end

  def self.all_cities(country_code, subdivision_code)
    connection.select_values("select distinct city from courses where country='#{country_code}' and state='#{subdivision_code}' order by name")
  end
    
  def self.with_location(country, subdivisions, city = nil, &block)
    if city
      conditions = ['country=? and state in (?) and city=?', country, subdivisions, city]
    elsif country && subdivisions.any?
      conditions = ['country=? and state in (?)', country, subdivisions]
    elsif country
      conditions = ['country=?', country]
    else
      conditions = ['1=1']
    end
    
    Course.with_scope(:find => { :conditions => conditions }) do
      yield
    end
  end
  
  def self.find_all_by_latlng(location, within=15)    
    res = GeoKit::Geocoders::GoogleGeocoder.geocode(location)
    return res, [] unless res.success
    
    return res, Course.find(:all, :origin => res.ll, :within => within, :order => 'name')
  end
  
  def self.find_all_by_name_like(name, page=1)
    Course.paginate(
        :all, 
        :order => 'name', 
        :conditions => ["name like ?", '%' + name.downcase.strip + '%'], 
        :page => page)
  end
  
  def self.popular(limit=25)
    Course.find(:all,
                :select => 'courses.*, count(1) rounds_played',
                :joins => 'join rounds on courses.id=rounds.course_id',
                :group => 'rounds.course_id',
                :order => 'rounds_played desc',
                :limit => limit)                            
  end

  def self.longest(limit=25)
    Course.find(:all, :order => 'yards desc', :limit => limit)                            
  end

  def self.unmapped(limit=25)
    Course.find(:all, :conditions => 'latitude is null', :order => 'name', :limit => limit)                            
  end

  def self.badaddress(limit=25)
    Course.find(:all, :conditions => 'city is null or state is null or country is null', :order => 'name', :limit => limit)                            
  end
    
  def self.oldest(limit=25)
    Course.find(:all, 
                :conditions => 'year_built is not null', 
                :order => 'year_built',
                :limit => limit)
  end

  def self.northern_most(limit=25)
    Course.find(:all, 
                :conditions => 'latitude is not null', 
                :order => 'latitude desc',
                :limit => limit)
  end
  
  def self.reviewed(limit=25)
    Course.find(:all,
                :select => 'courses.*',
                :joins => 'join reviews on courses.id=reviews.type_id and reviews.type="CourseReview"',
                :group => 'courses.id',
                :order => 'reviews.created_at desc',
                :limit => limit)     
  end
     
#  def self.find_name(page=1)
#    Course.paginate(:all, :order => 'name', :page => page)                            
#  end
    
  def scorecard
    @scorecard = ScorecardBang.new    
    @scorecard.holes = holes
    @scorecard
  end
  
  def complete?
    status == COMPLETE
  end

  def complete_with_tees?
    status == COMPLETE_WITH_TEES
  end
    
  def mappable?
    self.latitude && self.longitude
  end
  
  def top_tips
    Tip.find_top_tips_by_course(self)
  end
  
  def default_tee
    #TODO: this should come from the database
    tees[0]
  end

  def name
    read_attribute("name").titlecase
  end
  
  def short_name
    name.gsub(/(golf course)/i, "GC").gsub(/(country club)/i, "CC")
  end
  
  def street=(street)
#    @recode = true if read_attribute(:street) != street
    write_attribute(:street, street)
  end

  def city=(city)
#    @recode = true if read_attribute(:city) != city
    write_attribute(:city, city)
  end

  def state=(state)
#    @recode = true if read_attribute(:state) != state
    write_attribute(:state, state)
  end

  def country=(country)
#    @recode = true if read_attribute(:country) != country
    write_attribute(:country, country)
  end

  def postal_code=(postal_code)
#    @recode = true if read_attribute(:postal_code) != postal_code
    write_attribute(:postal_code, postal_code)
  end

  def par(range = 0..17)
    return read_attribute(:par) if range == (0..17) || holes.empty?
    total = 0 
    holes[range].each { |h| total += h.par }
    total
  end
  
  def to_json
    {
      :id => id,
      :name => name,
      :street => address.street,
      :city => address.city,
      :state => address.state,
      :country => address.country,
      :postal_code => address.postal_code,
      :phone => address.phone,
      :url => url,
      :display_url => (url.nil? ? "" : url[/(http:\/\/[^\/]*)/]),
      :club_type => (club_type.nil? ? "N/A" : CLUB_TYPES.index(club_type)),
      :number_of_holes => number_of_holes,
      :length => (yards.nil? ? "N/A" : "#{yards} #{length_units}"),
      :par => par || "N/A",
      :fee_range => (fee_range.nil? ? "N/A" : FEE_RANGES.index(fee_range)),
      :designer => designer || "N/A",
      :year_built => year_built || "N/A",
      :latitude => latitude,
      :longitude => longitude
    }.to_json
  end
  
#  def self.load_geocodes (courses)
#    courses.each do |c|
#      logger.debug("geocoding #{c.name}")
##      c.latitude, c.longitude = GeoKit::Geocoders::GoogleGeocoder.coordinates(c)
#      c.save
#      # throttle
#      sleep 1
#    end    
#  end
#  
#  private
#  

  def geocode_address
    if self.latitude.blank? || self.longitude.blank?
      self.latitude, self.longitude = address.geocode
    end
  end
  
end
