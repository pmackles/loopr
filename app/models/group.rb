class Group < ActiveRecord::Base
  MEMBER_ROLE = 0
  ADMIN_ROLE = 1
  CREATE_ROLE = 2
  
  has_many :memberships

  has_many :members, 
        :through => :memberships, 
        :source => :user, 
        :select => "users.*, memberships.role as group_role",
        :order => "user_id"
   
  validates_presence_of :name      
  validates_length_of :name, :within => 3..25
  validates_uniqueness_of :name
  
  def member?(user)
    members.include?(user)
  end

  def rounds
    @rounds ||= Round.list(:conditions => ['user_id in (?)', members.collect { |m| m.id }], :order => 'date_played desc')
  end
  
  def admin?(user)
    authorized?(user)
  end
  
  def authorized?(user)
    members.detect { |m| (m == user and m.group_role != "0") }
  end
  
  def courses
    all = members.collect do |u| 
      u.saved_courses.of_type(0).collect { |sc| sc.course } 
    end
    
    all.flatten.uniq
  end
  
  def members_with_stats
    members.select { |u| u.stats }
  end
  
  def best(metric)
    @sorter ||= StatSorter.new(members_with_stats.collect { |u| [u, u.stats] } )
    @sorter.best(metric)
  end
  
end
