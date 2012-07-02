class OutingObserver < ActiveRecord::Observer
  observe Round
  
#  def after_destroy(round)
#    after_save(round)
#  end
  
  def after_save(round)
    round.logger.debug("OutingObserver.after_save")
    user = round.user
    user.memberships.each { |m|
      Outing.create_if_needed(round, m.group)
    }
  end
end