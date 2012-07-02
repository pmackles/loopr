class Review < ActiveRecord::Base

  RATINGS = [["Bad", 1], 
             ["Not So Good", 2], 
             ["OK", 3], 
             ["Very Good", 4], 
             ["Excellent", 5]]

  belongs_to :user
  
  validates_inclusion_of :rating, :in => 1..5, :message => "required"

end
