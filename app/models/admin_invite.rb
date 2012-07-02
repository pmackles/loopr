class AdminInvite < Invite
  
  def send_email
    AdminMailer.deliver_invite(self)
  end

#  def accept(user)
#      if logged_in?(user)
#        errors.add_to_base("You are already a member")
#        return false
#      end
#  end
  
  def success_url
    {:controller => ''}
  end

  def success_msg
    "Welcome! You are now a member."
  end
    
end