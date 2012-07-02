class CourseReview < Review
  belongs_to :course, :foreign_key => :type_id
  
  validates_uniqueness_of :type_id, :scope => :user_id, 
                          :message => "You already submitted a review for this course"
    
  def self.summarize(course)
    results = ActiveRecord::Base.connection.select_one(
          "select avg(rating) as average_rating, " +
          "  count(1) total_ratings" +
          " from reviews " +
          " where type_id=#{course.id} " +
          "  and type='CourseReview' ")
    total_reviews = ActiveRecord::Base.connection.select_value(
          "select count(1) total_reviews" +
          " from reviews " +
          " where type_id=#{course.id} " +
          "  and type='CourseReview' and status=0")
          
    return results['average_rating'], total_reviews, results['total_ratings']
  end
  
  def self.list(options= {})
    find(:all, options.reverse_merge({ :select => "reviews.*, u.login as user_login, u.icon_url as user_icon_url, u.source as user_source, u.facebook_name as user_facebook_name", :joins => "join users u on (reviews.user_id=u.id)", :limit => 20, :conditions => "1=1", :order => "created_at desc" }))
  end
  
end