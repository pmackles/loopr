class CourseGeocodeObserver < ActiveRecord::Observer
  observe Map
  
  def after_save(map)
    map.course.latitude = map.latitude
    map.course.longitude = map.longitude
    map.course.save
  end
end