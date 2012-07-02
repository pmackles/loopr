class Tip < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
  
  validates_presence_of :content, :message => "required"
  
#  def self.find_top_tips_by_course(course)
#    Tip.find(:all, :conditions => ['course_id=?', course.id], 
#             :order => 'created_at desc', :limit => 10)
#  end
end
