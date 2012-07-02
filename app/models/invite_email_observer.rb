class InviteEmailObserver < ActiveRecord::Observer
  observe GroupInvite, AdminInvite

  def after_save(invite)
#    email = GroupMailer.deliver_invite(invite)
    email = invite.send_email
  end
  
end
