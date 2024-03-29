module Geography

  class Region
    def self.find_by_name(name)
      REGIONS[name]
    end
  
    def self.find_by_country_and_subdivision(country_code, subdivision_code)
      REGIONS.values.find do |r| 
        r.country_code == country_code && (subdivision_code.blank? || r.subdivisions.ordered.find { |s| s.first == subdivision_code } )
      end
    end
    
    def self.all
      REGIONS.values.sort { |a,b| a.name <=> b.name }
    end
  end
  
  private
  
  def self.subdivision(args)
    country_code = args[:country_code]
    code = args[:code]
    name = args[:name]
    region = args[:region] || COUNTRIES[args[:country_code]]
    
    SUBDIVISIONS[country_code] = {} unless SUBDIVISIONS[country_code] 
    SUBDIVISIONS[country_code][code] = name

    SUBDIVISIONS_X[country_code] = {} unless SUBDIVISIONS_X[country_code] 
    SUBDIVISIONS_X[country_code][name] = code

    REGIONS[region].subdivisions.ordered << [code, name]
    REGIONS[region].subdivisions.codes[name] = code
  end
  
  def self.country(args)
    COUNTRIES[args[:code]] = args[:name]
    COUNTRIES_X[args[:name]] = args[:code] 
  end
  
  def self.region(args)
    region = OpenStruct.new(args)
    region.subdivisions = OpenStruct.new
    region.subdivisions.ordered = []
    region.subdivisions.codes = {}
    region.is_country = COUNTRIES_X.has_key?(region.name)
    region.display_name = region.name unless region.display_name
    REGIONS[region.name] = region
  end
  
  COUNTRIES = {}
  COUNTRIES_X = {}
  SUBDIVISIONS = {}
  SUBDIVISIONS_X = {}
  REGIONS = {}

  country :code => 'US', :name => 'United States'
  country :code => 'CA', :name => 'Canada'
  country :code => 'GB', :name => 'United Kingdom'
  country :code => 'ZA', :name => 'South Africa'
  country :code => 'AU', :name => 'Australia'
  country :code => 'NZ', :name => 'New Zealand'
  country :code => 'BW', :name => 'Botswana'
  country :code => 'MY', :name => 'Malaysia'
  country :code => 'MX', :name => 'Mexico'
  country :code => 'IE', :name => 'Ireland'
  country :code => 'SG', :name => 'Singapore'
  country :code => 'AG', :name => 'Antigua and Barbuda'
  country :code => 'BB', :name => 'Barbados'
  country :code => 'CU', :name => 'Cuba'
  country :code => 'DO', :name => 'Dominican Republic'
  country :code => 'JM', :name => 'Jamaica'
  country :code => 'FR', :name => 'France'
  country :code => 'ES', :name => 'Spain'
  country :code => 'KY', :name => 'Cayman Islands'
  country :code => 'JP', :name => 'Japan'
  country :code => 'CN', :name => 'China'
  country :code => 'ID', :name => 'Indonesia'
  country :code => 'IN', :name => 'India'
  country :code => 'PT', :name => 'Portugal'
  country :code => 'BN', :name => 'Brunei'
  country :code => 'BS', :name => 'Bahamas'
  country :code => 'AW', :name => 'Aruba'
  country :code => 'PH', :name => 'Philippines'
  country :code => 'VN', :name => 'Vietnam'
  country :code => 'TC', :name => 'Turks and Caicos Islands'
  country :code => 'AE', :name => 'United Arab Emirates'
  country :code => 'DE', :name => 'Germany'
  country :code => 'IT', :name => 'Italy'
  country :code => 'BE', :name => 'Belgium'
  country :code => 'DK', :name => 'Denmark'
  country :code => 'FI', :name => 'Finland'
  country :code => 'SE', :name => 'Sweden'
  country :code => 'GR', :name => 'Greece'
  country :code => 'HK', :name => 'Hong Kong'
  country :code => 'HU', :name => 'Hungary'
  country :code => 'QA', :name => 'Qatar'
  country :code => 'TH', :name => 'Thailand'
  country :code => 'KE', :name => 'Kenya'
  country :code => 'NL', :name => 'Netherlands'
  country :code => 'KR', :name => 'South Korea'
  country :code => 'BM', :name => 'Bermuda'
  country :code => 'AR', :name => 'Argentina'
  country :code => 'TZ', :name => 'Tanzania'
  country :code => 'EG', :name => 'Egypt'
  country :code =>'MA', :name => 'Morocco'
  country :code =>'MU', :name => 'Mauritius'
  
  region :name => "Canada", :country_code => "CA"
  region :name => "United States", :country_code => "US", :display_name => 'The United States'
  region :name => "Scotland", :country_code => "GB"
  region :name => "England", :country_code => "GB"
  region :name => "Wales", :country_code => "GB"
  region :name => "Northern Ireland", :country_code => "GB"
  region :name => "Australia", :country_code => "AU"
  region :name => "South Africa", :country_code => "ZA"
  region :name => "Ireland", :country_code => "IE"
  region :name => "New Zealand", :country_code => "NZ"
  region :name => "Mexico", :country_code => "MX"
  region :name => 'Malaysia', :country_code => 'MY'
  region :name => 'Botswana', :country_code => 'BW'
  region :name => 'Channel Islands', :country_code => 'GB'
  region :name => 'Singapore', :country_code => 'SG'
  region :name => 'Antigua and Barbuda', :country_code => 'AG'
  region :name => 'Barbados', :country_code => 'BB'
  region :name => 'Cuba', :country_code => 'CU'
  region :name => 'Dominican Republic', :country_code => 'DO'
  region :name => 'Jamaica', :country_code => 'JM'
  region :country_code => 'FR', :name => 'France'
  region :country_code => 'ES', :name => 'Spain'
  region :country_code => 'KY', :name => 'Cayman Islands'
  region :country_code => 'JP', :name => 'Japan'
  region :country_code => 'CN', :name => 'China'
  region :country_code => 'ID', :name => 'Indonesia'
  region :country_code => 'IN', :name => 'India'
  region :country_code => 'PT', :name => 'Portugal'
  region :country_code => 'BN', :name => 'Brunei'
  region :country_code => 'BS', :name => 'Bahamas'
  region :country_code => 'AW', :name => 'Aruba'
  region :country_code => 'PH', :name => 'Philippines'
  region :country_code => 'VN', :name => 'Vietnam'
  region :country_code => 'TC', :name => 'Turks and Caicos Islands'
  region :country_code => 'AE', :name => 'United Arab Emirates'
  region :country_code => 'DE', :name => 'Germany'
  region :country_code => 'IT', :name => 'Italy'
  region :country_code => 'BE', :name => 'Belgium'
  region :country_code => 'DK', :name => 'Denmark'
  region :country_code => 'FI', :name => 'Finland'
  region :country_code => 'SE', :name => 'Sweden'
  region :country_code => 'GR', :name => 'Greece'
  region :country_code => 'HK', :name => 'Hong Kong'
  region :country_code => 'HU', :name => 'Hungary'
  region :country_code => 'QA', :name => 'Qatar'
  region :country_code => 'TH', :name => 'Thailand'
  region :country_code => 'KE', :name => 'Kenya'
  region :country_code => 'NL', :name => 'Netherlands'
  region :country_code => 'KR', :name => 'South Korea'
  region :country_code => 'BM', :name => 'Bermuda'
  region :country_code => 'AR', :name => 'Argentina'
  region :country_code => 'TZ', :name => 'Tanzania'
  region :country_code => 'EG', :name => 'Egypt'
  region :country_code =>'MA', :name => 'Morocco'
  region :country_code =>'MU', :name => 'Mauritius'
              
  subdivision :country_code => 'US', :code => 'AL', :name => 'Alabama'
  subdivision :country_code => 'US', :code => 'AK', :name => 'Alaska'
  subdivision :country_code => 'US', :code => 'AZ', :name => 'Arizona'
  subdivision :country_code => 'US', :code => 'AR', :name => 'Arkansas'
  subdivision :country_code => 'US', :code => 'CA', :name => 'California'
  subdivision :country_code => 'US', :code => 'CO', :name => 'Colorado'
  subdivision :country_code => 'US', :code => 'CT', :name => 'Connecticut'
  subdivision :country_code => 'US', :code => 'DE', :name => 'Delaware'
  subdivision :country_code => 'US', :code => 'DC', :name => 'District of Columbia'
  subdivision :country_code => 'US', :code => 'FL', :name => 'Florida'
  subdivision :country_code => 'US', :code => 'GA', :name => 'Georgia'
  subdivision :country_code => 'US', :code => 'GU', :name => 'Guam'
  subdivision :country_code => 'US', :code => 'HI', :name => 'Hawaii'
  subdivision :country_code => 'US', :code => 'ID', :name => 'Idaho'
  subdivision :country_code => 'US', :code => 'IL', :name => 'Illinois'
  subdivision :country_code => 'US', :code => 'IN', :name => 'Indiana'
  subdivision :country_code => 'US', :code => 'IA', :name => 'Iowa'
  subdivision :country_code => 'US', :code => 'KS', :name => 'Kansas'
  subdivision :country_code => 'US', :code => 'KY', :name => 'Kentucky'
  subdivision :country_code => 'US', :code => 'LA', :name => 'Louisiana'
  subdivision :country_code => 'US', :code => 'ME', :name => 'Maine'
  subdivision :country_code => 'US', :code => 'MD', :name => 'Maryland'
  subdivision :country_code => 'US', :code => 'MA', :name => 'Massachusetts'
  subdivision :country_code => 'US', :code => 'MI', :name => 'Michigan'
  subdivision :country_code => 'US', :code => 'MN', :name => 'Minnesota'
  subdivision :country_code => 'US', :code => 'MS', :name => 'Mississippi'
  subdivision :country_code => 'US', :code => 'MO', :name => 'Missouri'
  subdivision :country_code => 'US', :code => 'MT', :name => 'Montana'
  subdivision :country_code => 'US', :code => 'NE', :name => 'Nebraska'
  subdivision :country_code => 'US', :code => 'NV', :name => 'Nevada'
  subdivision :country_code => 'US', :code => 'NH', :name => 'New Hampshire'
  subdivision :country_code => 'US', :code => 'NJ', :name => 'New Jersey'
  subdivision :country_code => 'US', :code => 'NM', :name => 'New Mexico'
  subdivision :country_code => 'US', :code => 'NY', :name => 'New York'
  subdivision :country_code => 'US', :code => 'NC', :name => 'North Carolina'
  subdivision :country_code => 'US', :code => 'ND', :name => 'North Dakota'
  subdivision :country_code => 'US', :code => 'OH', :name => 'Ohio'
  subdivision :country_code => 'US', :code => 'OK', :name => 'Oklahoma'
  subdivision :country_code => 'US', :code => 'OR', :name => 'Oregon'
  subdivision :country_code => 'US', :code => 'PA', :name => 'Pennsylvania'
  subdivision :country_code => 'US', :code => 'PR', :name => 'Puerto Rico'
  subdivision :country_code => 'US', :code => 'RI', :name => 'Rhode Island'
  subdivision :country_code => 'US', :code => 'SC', :name => 'South Carolina'
  subdivision :country_code => 'US', :code => 'SD', :name => 'South Dakota'
  subdivision :country_code => 'US', :code => 'TN', :name => 'Tennessee'
  subdivision :country_code => 'US', :code => 'TX', :name => 'Texas'
  subdivision :country_code => 'US', :code => 'VI', :name => 'US Virgin Islands'
  subdivision :country_code => 'US', :code => 'UT', :name => 'Utah'
  subdivision :country_code => 'US', :code => 'VT', :name => 'Vermont'
  subdivision :country_code => 'US', :code => 'VA', :name => 'Virginia'
  subdivision :country_code => 'US', :code => 'WA', :name => 'Washington'
  subdivision :country_code => 'US', :code => 'WV', :name => 'West Virginia'
  subdivision :country_code => 'US', :code => 'WI', :name => 'Wisconsin'
  subdivision :country_code => 'US', :code => 'WY', :name => 'Wyoming'

#  subdivision :country_code => 'MX', :code => 'BCN', :name => 'Baja California'
#  subdivision :country_code => 'MX', :code => 'EME', :name => 'Estado de Mexico'
#  subdivision :country_code => 'MX', :code => 'HID', :name => 'Hidalgo'
#  subdivision :country_code => 'MX', :code => 'JAL', :name => 'Jalisco'
#  subdivision :country_code => 'MX', :code => 'GRO', :name => 'Guerrero'
#  subdivision :country_code => 'MX', :code => 'MOR', :name => 'Morelos'
#  subdivision :country_code => 'MX', :code => 'NLE', :name => 'Nuevo Leon'
#  subdivision :country_code => 'MX', :code => 'PUE', :name => 'Puebla'
#  subdivision :country_code => 'MX', :code => 'ROO', :name => 'Quintana Roo'
    
  subdivision :country_code => 'CA', :code => 'AB', :name => 'Alberta'
  subdivision :country_code => 'CA', :code => 'BC', :name => 'British Columbia'
  subdivision :country_code => 'CA', :code => 'MB', :name => 'Manitoba'
  subdivision :country_code => 'CA', :code => 'NB', :name => 'New Brunswick'
  subdivision :country_code => 'CA', :code => 'NL', :name => 'Newfoundland and Labrador'
  subdivision :country_code => 'CA', :code => 'NT', :name => 'Northwest Territories'
  subdivision :country_code => 'CA', :code => 'NS', :name => 'Nova Scotia'
  subdivision :country_code => 'CA', :code => 'NU', :name => 'Nunavut'
  subdivision :country_code => 'CA', :code => 'ON', :name => 'Ontario'
  subdivision :country_code => 'CA', :code => 'PE', :name => 'Prince Edward Island'
  subdivision :country_code => 'CA', :code => 'QC', :name => 'Quebec'
  subdivision :country_code => 'CA', :code => 'SK', :name => 'Saskatchewan'
  subdivision :country_code => 'CA', :code => 'YT', :name => 'Yukon'

  subdivision :country_code => 'AU', :code => 'ACT', :name => 'Capital Territory'
  subdivision :country_code => 'AU', :code => 'NSW', :name => 'New South Wales'
  subdivision :country_code => 'AU', :code => 'NT', :name => 'Northern Territory'
  subdivision :country_code => 'AU', :code => 'QLD', :name => 'Queensland'
  subdivision :country_code => 'AU', :code => 'SA', :name => 'South Australia'
  subdivision :country_code => 'AU', :code => 'TAS', :name => 'Tasmania'
  subdivision :country_code => 'AU', :code => 'VIC', :name => 'Victoria'
  subdivision :country_code => 'AU', :code => 'WA', :name => 'Western Australia'

  subdivision :country_code => 'NZ', :code => 'AUK', :name => 'Auckland'
  subdivision :country_code => 'NZ', :code => 'BOP', :name => 'Bay of Plenty'
  subdivision :country_code => 'NZ', :code => 'CAN', :name => 'Canterbury'
  subdivision :country_code => 'NZ', :code => 'GIS', :name => 'Gisborne'
  subdivision :country_code => 'NZ', :code => 'HKB', :name => 'Hawke\'s Bay'
  subdivision :country_code => 'NZ', :code => 'MBH', :name => 'Marlborough'
  subdivision :country_code => 'NZ', :code => 'MWT', :name => 'Manawatu-Wanganui'
  subdivision :country_code => 'NZ', :code => 'NSN', :name => 'Nelson'
  subdivision :country_code => 'NZ', :code => 'NTL', :name => 'Northland'
  subdivision :country_code => 'NZ', :code => 'OTA', :name => 'Otago'
  subdivision :country_code => 'NZ', :code => 'STL', :name => 'Southland'
  subdivision :country_code => 'NZ', :code => 'TAS', :name => 'Tasman'
  subdivision :country_code => 'NZ', :code => 'TKI', :name => 'Taranaki'
  subdivision :country_code => 'NZ', :code => 'WGN', :name => 'Wellington'
  subdivision :country_code => 'NZ', :code => 'WKO', :name => 'Waikato'
  subdivision :country_code => 'NZ', :code => 'WTC', :name => 'West Coast'
    
  subdivision :country_code => 'ZA', :code => 'EC', :name => 'Eastern Cape'
  subdivision :country_code => 'ZA', :code => 'FS', :name => 'Free State'
  subdivision :country_code => 'ZA', :code => 'GT', :name => 'Gauteng'
  subdivision :country_code => 'ZA', :code => 'NL', :name => 'KwaZulu-Natal'
  subdivision :country_code => 'ZA', :code => 'NP', :name => 'Limpopo'
  subdivision :country_code => 'ZA', :code => 'MP', :name => 'Mpumalanga'
  subdivision :country_code => 'ZA', :code => 'NC', :name => 'Northern Cape'
  subdivision :country_code => 'ZA', :code => 'NW', :name => 'North-West'
  subdivision :country_code => 'ZA', :code => 'WC', :name => 'Western Cape'
    
  subdivision :country_code => 'MY', :code => '01', :name => 'Johor'
  subdivision :country_code => 'MY', :code => '02', :name => 'Kedah'
  subdivision :country_code => 'MY', :code => '03', :name => 'Kelantan'
  subdivision :country_code => 'MY', :code => '04', :name => 'Melaka'
  subdivision :country_code => 'MY', :code => '05', :name => 'Negeri Sembilan'
  subdivision :country_code => 'MY', :code => '06', :name => 'Pahang'
  subdivision :country_code => 'MY', :code => '07', :name => 'Pulau Pinang'
  subdivision :country_code => 'MY', :code => '08', :name => 'Perak'
  subdivision :country_code => 'MY', :code => '09', :name => 'Perlis'
  subdivision :country_code => 'MY', :code => '10', :name => 'Selangor'
  subdivision :country_code => 'MY', :code => '11', :name => 'Terengganu'
  subdivision :country_code => 'MY', :code => '12', :name => 'Sabah'
  subdivision :country_code => 'MY', :code => '13', :name => 'Sarawak'
  subdivision :country_code => 'MY', :code => '14', :name => 'Kuala Lumpur'
  subdivision :country_code => 'MY', :code => '15', :name => 'Labuan'
  subdivision :country_code => 'MY', :code => '16', :name => 'Putrajaya'

  subdivision :country_code => 'BW', :code => 'CE', :name => 'Central'
  subdivision :country_code => 'BW', :code => 'GH', :name => 'Ghanzi'
  subdivision :country_code => 'BW', :code => 'KG', :name => 'Kgalagadi'
  subdivision :country_code => 'BW', :code => 'KL', :name => 'Kgatleng'
  subdivision :country_code => 'BW', :code => 'KW', :name => 'Kweneng'
  subdivision :country_code => 'BW', :code => 'NE', :name => 'North-East'
  subdivision :country_code => 'BW', :code => 'NW', :name => 'North-West'
  subdivision :country_code => 'BW', :code => 'SE', :name => 'South-East'
  subdivision :country_code => 'BW', :code => 'SO', :name => 'Southern'
    
  subdivision :country_code => 'IE', :code => 'C', :name => 'Cork'
  subdivision :country_code => 'IE', :code => 'CE', :name => 'Clare'
  subdivision :country_code => 'IE', :code => 'CN', :name => 'Cavan'
  subdivision :country_code => 'IE', :code => 'CW', :name => 'Carlow'
  subdivision :country_code => 'IE', :code => 'D', :name => 'Dublin'
  subdivision :country_code => 'IE', :code => 'DL', :name => 'Donegal'
  subdivision :country_code => 'IE', :code => 'G', :name => 'Galway'
  subdivision :country_code => 'IE', :code => 'KE', :name => 'Kildare'
  subdivision :country_code => 'IE', :code => 'KK', :name => 'Kilkenny'
  subdivision :country_code => 'IE', :code => 'KY', :name => 'Kerry'
  subdivision :country_code => 'IE', :code => 'LD', :name => 'Longford'
  subdivision :country_code => 'IE', :code => 'LH', :name => 'Louth'
  subdivision :country_code => 'IE', :code => 'LK', :name => 'Limerick'
  subdivision :country_code => 'IE', :code => 'LM', :name => 'Leitrim'
  subdivision :country_code => 'IE', :code => 'LS', :name => 'Laois'
  subdivision :country_code => 'IE', :code => 'MH', :name => 'Meath'
  subdivision :country_code => 'IE', :code => 'MN', :name => 'Monaghan'
  subdivision :country_code => 'IE', :code => 'MO', :name => 'Mayo'
  subdivision :country_code => 'IE', :code => 'OY', :name => 'Offaly'
  subdivision :country_code => 'IE', :code => 'RN', :name => 'Roscommon'
  subdivision :country_code => 'IE', :code => 'SO', :name => 'Sligo'
  subdivision :country_code => 'IE', :code => 'TA', :name => 'Tipperary'
  subdivision :country_code => 'IE', :code => 'WD', :name => 'Waterford'
  subdivision :country_code => 'IE', :code => 'WH', :name => 'Westmeath'
  subdivision :country_code => 'IE', :code => 'WW', :name => 'Wicklow'
  subdivision :country_code => 'IE', :code => 'WX', :name => 'Wexford'

  subdivision :country_code => 'GB', :name => 'Blaenau Gwent', :code => 'BGW', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Bridgend', :code => 'BGE', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Caerphilly', :code => 'CAY', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Ceredigion', :code => 'CGN', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Conwy', :code => 'CWY', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Denbighshire', :code => 'DEN', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Flintshire', :code => 'FLN', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Gwynedd', :code => 'GWN', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Isle of Anglesey', :code => 'AGY', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Merthyr Tydfil', :code => 'MTY', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Monmouthshire', :code => 'MON', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Neath Port Talbot', :code => 'NTL', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Newport', :code => 'NWP', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Rhondda Cynon Taff', :code => 'RCT', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Swansea', :code => 'SWA', :region => 'Wales'
  subdivision :country_code => 'GB', :name => 'Torfaen', :code => 'TOF', :region => 'Wales'
  subdivision :country_code => 'GB', :code => 'CRF', :name => 'Cardiff', :region => 'Wales'
  subdivision :country_code => 'GB', :code => 'WRX', :name => 'Wrexham', :region => 'Wales'
  subdivision :country_code => 'GB', :code => 'POW', :name => 'Powys', :region => 'Wales'
  subdivision :country_code => 'GB', :code => 'VGL', :name => 'West Glamorgan', :region => 'Wales'
  subdivision :country_code => 'GB', :code => 'CMN', :name => 'Carmarthenshire', :region => 'Wales'
  subdivision :country_code => 'GB', :code => 'PEM', :name => 'Pembrokeshire', :region => 'Wales'
  
  subdivision :country_code => 'GB', :code =>'ABD', :name => 'Aberdeenshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'ANS', :name => 'Angus', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'ARL', :name => 'Argyllshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'AYR', :name => 'Ayrshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'BAN', :name => 'Banffshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'BEW', :name => 'Berwickshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'BOR', :name => 'Borders', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'BUT', :name => 'Bute', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'CAI', :name => 'Caithness', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'CEN', :name => 'Central', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'CLK', :name => 'Clackmannanshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'DGY', :name => 'Dumfries and Galloway', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'DFS', :name => 'Dumfries-shire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'DNB', :name => 'Dunbartonshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'ELN', :name => 'East Lothian', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'FIF', :name => 'Fife', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'GLG', :name => 'Glasgow', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'GMP', :name => 'Grampian', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'HLD', :name => 'Highland', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'INV', :name => 'Inverness-shire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'KCD', :name => 'Kincardineshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'KRS', :name => 'Kinross-shire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'KKD', :name => 'Kirkcudbrightshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'LKS', :name => 'Lanarkshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'LTN', :name => 'Lothian', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'MLN', :name => 'Midlothian', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'MOR', :name => 'Morayshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'NAI', :name => 'Nairn', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'OKI', :name => 'Orkney', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'PEE', :name => 'Peebles-shire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'PER', :name => 'Perth', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'RFW', :name => 'Renfrewshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'ROC', :name => 'Ross and Cromarty', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'ROX', :name => 'Roxburghshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'SEL', :name => 'Selkirkshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'SHI', :name => 'Shetland', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'STI', :name => 'Stirlingshire', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'STD', :name => 'Strathclyde', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'SUT', :name => 'Sutherland', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'TAY', :name => 'Tayside', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'WLN', :name => 'West Lothian', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'WIS', :name => 'Western Isles', :region => 'Scotland'
  subdivision :country_code => 'GB', :code =>'WIG', :name => 'Wigtownshire', :region => 'Scotland'
        
  subdivision :country_code => 'GB', :code =>'AVN', :name => 'Avon', :region => 'England'
  subdivision :country_code => 'GB', :code => 'BDF', :name => 'Bedfordshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'BRK', :name => 'Berkshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'BKM', :name => 'Buckinghamshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'CAM', :name => 'Cambridgeshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'CHS', :name => 'Cheshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'CLV', :name => 'Cleveland', :region => 'England'
  subdivision :country_code => 'GB', :code => 'DUR', :name => 'Co Durham', :region => 'England'
  subdivision :country_code => 'GB', :code => 'CON', :name => 'Cornwall', :region => 'England'
  subdivision :country_code => 'GB', :code => 'CUL', :name => 'Cumberland', :region => 'England'
  subdivision :country_code => 'GB', :code => 'CMA', :name => 'Cumbria', :region => 'England'
  subdivision :country_code => 'GB', :code => 'DBY', :name => 'Derbyshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'DEV', :name => 'Devon', :region => 'England'
  subdivision :country_code => 'GB', :code => 'DOR', :name => 'Dorset', :region => 'England'
  subdivision :country_code => 'GB', :code => 'ERY', :name => 'East Riding of Yorkshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'SXE', :name => 'East Sussex', :region => 'England'
  subdivision :country_code => 'GB', :code => 'ESS', :name => 'Essex', :region => 'England'
  subdivision :country_code => 'GB', :code => 'GLS', :name => 'Gloucestershire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'GTL', :name => 'Greater London', :region => 'England'
  subdivision :country_code => 'GB', :code => 'GTM', :name => 'Greater Manchester', :region => 'England'
  subdivision :country_code => 'GB', :code => 'HAM', :name => 'Hampshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'HWR', :name => 'Hereford and Worcester', :region => 'England'
  subdivision :country_code => 'GB', :code => 'HEF', :name => 'Herefordshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'HRT', :name => 'Hertfordshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'HUM', :name => 'Humberside', :region => 'England'
  subdivision :country_code => 'GB', :code => 'HUN', :name => 'Huntingdonshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'IOW', :name => 'Isle of Wight', :region => 'England'
  subdivision :country_code => 'GB', :code => 'KEN', :name => 'Kent', :region => 'England'
  subdivision :country_code => 'GB', :code => 'LAN', :name => 'Lancashire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'LEI', :name => 'Leicestershire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'LIN', :name => 'Lincolnshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'MDX', :name => 'Middlesex', :region => 'England'
  subdivision :country_code => 'GB', :code => 'MSY', :name => 'Merseyside', :region => 'England'
  subdivision :country_code => 'GB', :code => 'NFK', :name => 'Norfolk', :region => 'England'
  subdivision :country_code => 'GB', :code => 'NRY', :name => 'North Riding of Yorkshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'NYK', :name => 'North Yorkshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'NTH', :name => 'Northamptonshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'NBL', :name => 'Northumberland', :region => 'England'
  subdivision :country_code => 'GB', :code => 'NTT', :name => 'Nottinghamshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'OXF', :name => 'Oxfordshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'RUT', :name => 'Rutland', :region => 'England'
  subdivision :country_code => 'GB', :code => 'SAL', :name => 'Shropshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'SOM', :name => 'Somerset', :region => 'England'
  subdivision :country_code => 'GB', :code => 'SYK', :name => 'South Yorkshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'STS', :name => 'Staffordshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'SFK', :name => 'Suffolk', :region => 'England'
  subdivision :country_code => 'GB', :code => 'SRY', :name => 'Surrey', :region => 'England'
  subdivision :country_code => 'GB', :code => 'SSX', :name => 'Sussex', :region => 'England'
  subdivision :country_code => 'GB', :code => 'TWR', :name => 'Tyne and Wear', :region => 'England'
  subdivision :country_code => 'GB', :code => 'WAR', :name => 'Warwickshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'WMD', :name => 'West Midlands', :region => 'England'
  subdivision :country_code => 'GB', :code => 'WRY', :name => 'West Riding of Yorkshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'SXW', :name => 'West Sussex', :region => 'England'
  subdivision :country_code => 'GB', :code => 'WYK', :name => 'West Yorkshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'WES', :name => 'Westmorland', :region => 'England'
  subdivision :country_code => 'GB', :code => 'WIL', :name => 'Wiltshire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'WOR', :name => 'Worcestershire', :region => 'England'
  subdivision :country_code => 'GB', :code => 'YKS', :name => 'Yorkshire', :region => 'England'
        
  subdivision :country_code => 'GB', :code => 'ANT', :name => 'Co Antrim', :region => 'Northern Ireland'
  subdivision :country_code => 'GB', :code => 'ARM', :name => 'Co Armagh', :region => 'Northern Ireland'
  subdivision :country_code => 'GB', :code => 'DOW', :name => 'Co Down', :region => 'Northern Ireland'
  subdivision :country_code => 'GB', :code => 'FER', :name => 'Co Fermanagh', :region => 'Northern Ireland'
  subdivision :country_code => 'GB', :code => 'LDY', :name => 'Co Londonderry', :region => 'Northern Ireland'
  subdivision :country_code => 'GB', :code => 'TYR', :name => 'Co Tyrone', :region => 'Northern Ireland'

  subdivision :country_code => 'GB', :code => 'GSY', :name => 'Guernsey', :region => 'Channel Islands'
  subdivision :country_code => 'GB', :code => 'JSY', :name => 'Jersey', :region => 'Channel Islands'

end
