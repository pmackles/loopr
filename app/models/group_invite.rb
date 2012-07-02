class GroupInvite < Invite
  belongs_to :group

  def accept(user)
      if self.group.members.include?(user)
        errors.add_to_base("Already a member")
        return false
      else
        self.group.memberships << Membership.new(:user => user, :role => Group::MEMBER_ROLE)
        return true
      end
  end
  
  def send_email
    GroupMailer.deliver_invite(self)
  end
  
  def success_url
    {:controller => 'group', :action => 'show', :id => self.group}
  end
  
  def success_msg
    "Welcome! You are now a member."
  end
  
end
