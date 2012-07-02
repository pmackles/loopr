class Address
  def initialize(street, city, state, country, postal_code=nil, phone=nil)
    @street = street
    @city = city
    @state = state
    @country = country
    @postal_code = postal_code
    @phone = phone
  end
  
  def country
    Geography::COUNTRIES[@country]
  end
  
  def region
    Geography::Region.find_by_country_and_subdivision(@country, @state).name
  end
  
  def state
    Geography::SUBDIVISIONS[@country][@state] unless @state.blank?
  end
  
  def postal_code
    @postal_code
  end
  
  def city
    @city
  end
  
  def street
    @street
  end
  
  def phone
    @phone
  end
  
  def mappable?
    true unless @city.blank? || @country.blank?
  end
  
  def to_formatted_s(format = :full)
    if format == :short
      state.blank? ? "#{city}, #{country}" : "#{city}, #{state}, #{country}"
    elsif format == :really_short
      state.blank? ? "#{city}, #{country}" : "#{city}, #{state}"
    elsif format == :full
      loc = ""
      loc += (street + ", ") unless street.blank?
      loc += city 
      loc += (", " + state) unless state.blank?
      loc += ", " +  country
      loc
    end
  end
  
  def geocode
    variations = []
    variations << to_formatted_s(:full)
    variations << to_formatted_s(:short)
    variations << "#{state}, #{country}" unless state.blank?
    variations << country
    
    variations.each do |addr|
      puts addr
      geo = GeoKit::Geocoders::GoogleGeocoder.geocode(addr)
      return geo.lat,geo.lng if geo.success
    end
  end
  
end
