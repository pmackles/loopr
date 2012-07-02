class MembershipObserver < ActiveRecord::Observer
  observe Membership
  
#  def after_destroy(round)
#    after_save(round)
#  end
  
  def after_save(membership)
    group = membership.group
    user = membership.user
    user.rounds.each { |r|
      Outing.create_if_needed(r, group)
    }
  end
end