class FacebookClient

  class ClientException < Exception; end
  
  def feed_publish_action_of_user(options)
     response = call_method("feed.publishActionOfUser", options)
  end

  def feed_register_template_bundle(options)
     response = call_method("feed.registerTemplateBundle", options)
  end

  def feed_publish_user_action(options)
    response = call_method("feed.publishUserAction", options)
    RAILS_DEFAULT_LOGGER.debug("#{response}")
  end
      
  def profile_set_fbml(options)
    response = call_method("profile.setFBML", options)    
  end
  
  def get_session(auth_token)
    response = call_method("auth.getSession", :auth_token => auth_token)  
    session_key = (response/"auth_getSession_response/session_key").inner_text
    uid = (response/"auth_getSession_response/uid").inner_text
    expires = (response/"auth_getSession_response/expires").inner_text
    return session_key, uid, expires
  end
  
  def users_get_standard_info(uids)
    RAILS_DEFAULT_LOGGER.debug("calling users_get_standard_info for #{uids}")

    fetch_uids = if uids.is_a?(Array) 
      uids.select { |uid| user_cache[uid.to_i].nil? }
    else
      user_cache.has_key?(uids.to_i) ? [] : [uids]
    end
    
    if fetch_uids.any?
      RAILS_DEFAULT_LOGGER.debug("user #{fetch_uids} not in cache")
      response = call_method(
        "users.getInfo",
        :uids => fetch_uids,
        :fields => [:name, :pic_square]
      )
      
#      RAILS_DEFAULT_LOGGER.debug("xxddd #{response}")
      (response/"users_getInfo_response/user").each do |uinfo|
        add_to_user_cache uinfo
      end
    end
    
    if uids.is_a?(Array) 
      uids.collect { |uid| user_cache[uid.to_i] }
    else
      user_cache[uids.to_i]
    end
  end

  def friends_get_app_users(user)    
    unless user_friends_cache[user]
      response = call_method(
        "fql.query",
        :session_key => user.facebook_session_key,
        :query => "SELECT uid,name,pic_square,is_app_user FROM user WHERE (uid in (SELECT uid2 FROM friend WHERE uid1=#{user.facebook_id})  AND is_app_user)"
      )
  
      (response/"fql_query_response/user").collect do |uinfo|
        add_to_user_cache uinfo
        (uinfo/"uid").inner_text
      end
    end
    
  end
    
  private
  
  def add_to_user_cache(uinfo)
    ui = OpenStruct.new
    ui.uid = (uinfo/"uid").inner_text
    ui.name = (uinfo/"name").inner_text
    ui.pic_square = (uinfo/"pic_square").inner_text
#      ui.is_app_user = (uinfo/"is_app_user").inner_text
    if ui.pic_square.blank?
      ui.pic_square = "http://static.ak.facebook.com/pics/t_default.jpg"
    end
    user_cache[ui.uid.to_i] = ui
  end
  
  def user_cache
    @user_cache ||= Hash.new
  end

  def user_friends_cache
    @user_friends_cache ||= Hash.new
  end

  def call_method(method, params={}) 
    # set up params hash
    params = params ||= {}
    params[:method] = "facebook.#{method}"
    params[:api_key] = FACEBOOK_API_KEY
    params[:v] = "1.0"
    params[:call_id] = Time.now.to_f.to_s
    
    # convert arrays to comma-separated lists
    params.each{|k,v| params[k] = v.join(",") if v.is_a?(Array)}
    
    # set up the param_signature value in the params
    params[:sig] = param_signature(params)

    # do the request
    xmlstring = post_request(FacebookSession::API_SERVER_BASE_URL, FacebookSession::API_PATH_REST, method, params)
    xml = Hpricot.XML(xmlstring)

    # error checking    
    if xml.at("error_response")
      code = xml.at("error_code").inner_html
      msg = xml.at("error_msg").inner_html
      raise ClientException, "error - code: #{code}; msg: #{msg}; params: #{params}"
    end
    
    return xml
  end

  def post_request(api_server_base_url, api_server_path, method, params)
    
    # get a server handle
    http_server = Net::HTTP.new(api_server_base_url, 80)
    
    # build a request
    http_request = Net::HTTP::Post.new(api_server_path)
    http_request.form_data = params
    response = http_server.start{|http| http.request(http_request)}.body
    
    # return the text of the body
    return response
    
  end

  def param_signature(params)    
    return generate_signature(params, FACEBOOK_API_SECRET);
  end
  
  def generate_signature(hash, secret)
    
    args = []
    hash.each do |k,v|
      args << "#{k}=#{v}"
    end
    sortedArray = args.sort
    requestStr = sortedArray.join("")
    return Digest::MD5.hexdigest("#{requestStr}#{secret}")
    
  end  
end
