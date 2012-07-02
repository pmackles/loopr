module FbmlHelper
  def fb_profile_pic(user, options = {})
  	u = controller.fbsession.users_get_standard_info(user.facebook_id)
  	pic_square = (u.nil? || u.pic_square.blank?) ? "http://static.ak.facebook.com/pics/t_default.jpg" : u.pic_square
    image_tag(pic_square, :id => "media_header_picture")
  end

  def fb_name(user, options = {})
  	u = controller.fbsession.users_get_standard_info(user.facebook_id)
  	name = (u.nil? || u.name.blank?) ? "?" : u.name
  	same_as_current_user = u && current_user.facebook_id == u.uid.to_i
  	
  	if options[:possessive] == true
  	 same_as_current_user ? "My" : apostrophize(name)
  	else
  	 same_as_current_user ? "You" :name
  	end
  end
end
