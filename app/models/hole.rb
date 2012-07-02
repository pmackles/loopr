class Hole < ActiveRecord::Base
  belongs_to :course
  
  validates_inclusion_of :par, :in=>3..5 , 
    :message => "can only be 3, 4 or 5"

end
