class CoursesController < ApplicationController
  
  helper_method :courses_browse_url, :courses_search_url
  
  layout :courseslayout
    
#  def popular
#    @region = Geography::Region.find_by_name(params[:region])
#    if @region      
#      Course.with_location(@region.country_code, subdivisions) do
#        @courses = Course.find_popular params[:page]
#      end
#    else
#      @courses = Course.find_popular params[:page]
#    end
#  end

  def manage
  end
  
  def search
    q = params[:q]
    t = params[:t]
    page = params[:page] || 1
    
    if q.blank?
      render :action => :search_blank
      return
    end
        
    @courses = Course.find_all_by_name_like(q, page)
  end
  
  def searchloc
    q = params[:q]
    loc, courses = Course.find_all_by_latlng(q, 15)
    
    render :json => {
      :loc => {
        :success => loc.success,
        :full_address => loc.full_address,
        :lat => loc.lat,
        :lng => loc.lng
      },
      :courses => courses,
      :distances => courses.collect { |c| c.distance.to_i }
    }.to_json
  end
  
  def map
  end
  
  def index
    @featured = Course.find(26558, 27043)
    @longest = Course.find(27087, 6425)
    @oldest = Course.find(25529, 27167)
    @polar = Course.find(8046, 8037)
  end
  
  def browse
    @region = Geography::Region.find_by_name(params[:region].gsub(/_/, ' ')) if params.has_key?(:region)
    @subdivision = params[:subdivision].gsub(/_/, ' ') if params.has_key?(:subdivision)
    @city = params[:city].gsub(/_/, ' ') if params.has_key?(:city)
    
    page = params[:page] || 1

    if @region      
      Course.with_location(@region.country_code, subdivisions, @city) do
        @courses = Course.paginate(:all, :order => 'name', :page => page)
      end
      if @subdivision
        @cities = Course.top_cities(@region.country_code, @region.subdivisions.codes[@subdivision])
      end
    else
      @courses = Course.paginate(:all, :order => 'name', :page => page)
    end
    
    @location = location
    render :action => :browse
  end

  
  def cities
    @region = Geography::Region.find_by_name(params[:region].gsub(/_/, ' '))
    @subdivision = params[:subdivision].gsub(/_/, ' ')
    @groupings = Course.all_cities(@region.country_code, @region.subdivisions.codes[@subdivision]).group_by { |c| c.first }
  end

  def geocoder
    lat, lng = Address.new(params[:street], params[:city], params[:state], params[:country]).geocode
    render :layout => false, :json => { :latitude => lat, :longitude => lng }.to_json
  end
      
  private
  
  def location
    if @region && @subdivision && @city
	  "#{@city}, #{@subdivision}"
	elsif @region && @subdivision
	  @subdivision
	elsif @region
	  @region.display_name
	else
	  "Worldwide"
	end
  end
  
  def subdivisions
    if @subdivision
      [ @region.subdivisions.codes[@subdivision] ]
    elsif @region.is_country
      []
    else
      @region.subdivisions.ordered.collect { |s| s.first }
    end
  end
  
end
