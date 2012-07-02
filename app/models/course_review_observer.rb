class CourseReviewObserver < ActiveRecord::Observer
  observe CourseReview
  
  def after_destroy(round)
    after_save(round)
  end
  
  def after_save(review)
    course = review.course

    course.average_rating, course.total_reviews, course.total_ratings = 
      CourseReview.summarize(course)
    course.save    
  end
end