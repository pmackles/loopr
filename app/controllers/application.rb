require 'localization'
require 'user_system'

# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include Localization
  include UserSystem
 
#  model :secure_token, :scorecard, :stat_sorter

  before_filter :init
  before_filter :auto_login
  
  helper_method :current_user, :guest_user?, :logged_in?, :group_icon_path, :same_as_current_user?, :admin?, :me?
  helper :fbml, :user
  
  @@guest_user = User.new

  def userlayout
    params[:auth_token] || f8? ? "f8/user" : "user"  
  end

  def standardlayout
    params[:auth_token] || f8? ? "f8/standard" : "standard"  
  end

  def courseslayout
    params[:auth_token] || f8? ? "f8/courses" : "courses"  
  end

  def courselayout
    params[:auth_token] || f8? ? "f8/course" : "course"  
  end
      
  def default_url_options(options)
    if params[:auth_token] || f8?
      { :host => "#{FACEBOOK_DEFAULT_URL_OPTIONS[:host]}" }
    else 
      {}
    end
  end
    
  def init
    response.headers['P3P'] = 'CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"'
    @breadcrumb = Array.new
  end
        
  def admin?
    current_user.admin?
  end
  
  def me?
    # current_user.id == 1
    true
  end
  
  def admin_only
     unless admin?
      render :status => 403, :text => "Permission denied"
      return false
     end
  end

  def same_as_current_user?(user)
    current_user == user
  end
  
  def current_user
    session['user'] || @@guest_user
  end
  
  def group_icon_path(group)
    group.icon_url || "/images/default_group_icon.jpg"
  end
      
  def f8?
    params["fb_sig_in_iframe"] == "1" || params[:mode] == "f8"
  end
  
  def login_required
    return if logged_in?
    
    if f8?
      install_url = fbsession.get_install_url()
      render :text => "<script>top.location.href='#{install_url}';</script>"
      logger.info("login_required: sending user to: #{install_url}")
    else 
      respond_to do |format|
        format.html { redirect_to :controller => "account", :action => "account_needed" }
        format.js { render :nothing => true, :status => 403 } 
      end
    end
    
    return false
  end
      
  def logged_in?
    current_user != @@guest_user
  end
  
  def guest_user?
    current_user == @@guest_user || current_user == nil
  end
  
  def forget_user
    cookies[:user] = {:domain => COOKIE_DOMAIN, :expires => -1.year.from_now}
  end
  
  def remember_user(user)
    cookies[:user] = {
      :value => SecureToken.new(user.id, User.to_s).to_s,
      :expires => Time.gm(2037),
      :domain => COOKIE_DOMAIN,
    }
  end
  
  def fbsession
    @fbsession ||= FacebookSession.new(FACEBOOK_API_KEY, FACEBOOK_API_SECRET)
  end
  
  def agag
    logger.info("agag: attempting to login facebook user: #{fbsession.user}")
    if u = User.find_by_facebook_id(fbsession.user)
      logger.info("agag: found linked account: #{u.id}")
      # pickup the latest session key
      if u.facebook_session_key != fbsession.session_key
        logger.info("agag: updating session_key: #{u.id}")
        u.facebook_session_key = fbsession.session_key
        u.save!
      end
      session['user'] = u
    else
      logger.info("agag: could not find account: #{fbsession.user}")
      if logged_in?
        logger.info("agag: user is logged in, attempting to link to account: #{current_user.id}")
        current_user.facebook_id = fbsession.user
        current_user.facebook_session_key = fbsession.session_key
        current_user.save
      elsif cookies[:user]
        token = SecureToken.parse(User.to_s, cookies[:user])
        logger.info("agag: found user cookie, attempting to link to account: #{token.id}")
        session['user'] = User.find(token.id)          
        current_user.facebook_id = fbsession.userttt
        current_user.facebook_session_key = fbsession.session_key
        current_user.save
      else
        logger.info("agag: creating account for facebook_id: #{fbsession.user}")
        user = User.create(
          :password => "dUmMy123",
          :password_confirmation => "dUmMy123",
          :new_password => true,
          :facebook_id => fbsession.user,
          :login =>  "fb#{fbsession.user}",
          :email => "fb#{fbsession.user}@autofb.com",
          :source => "fb",
          :facebook_session_key => fbsession.session_key,
          :facebook_name => fbsession.users_get_standard_info(fbsession.user).first_name || 'Someone'
        )
        logger.debug("welcome: id=#{user.id}")
        session['user'] = user
      end
    end
  end
  
  # handle auto logins for both facebook and the standalone site. Give priority to params coming through the url.
  # For facebook, we need to be prepared for the "currently logged in user" to change at anytime so we need to
  # check the user_id of the session against the user_id specified in the query params
  def auto_login
    logger.info("auto_login: enter f8?=#{f8?}, guest_user=#{guest_user?}, current_user.id=#{current_user.id}")
  
    if f8?
      fbsession.activate(params)
      if fbsession.logged_out?
        logger.info("auto_login: user not logged into facebook")
        install_url = fbsession.get_install_url()
        render :text => "<script>top.location.href='#{install_url}';</script>"
        return false
      elsif fbsession.in_profile_tab?
        return
      elsif fbsession.is_valid? && fbsession.session_key != current_user.facebook_session_key
        agag
      elsif fbsession.is_valid? && fbsession.session_key == current_user.facebook_session_key
        logger.info("auto_login: already logged in")
      else 
        logger.info("auto_login: guest facebook user")
        reset_session        
      end

      unless fbsession.in_iframe?
        render :text => "<script>top.location.href='http://#{FACEBOOK_DEFAULT_URL_OPTIONS[:host]}/';</script>"
        return false
      end
              
    elsif params['user'] && params['key']
      logger.info("auto_login: found token, loading account")
      id = params['user']['id']
      key = params['key']
      if id and key
        session['user'] = User.authenticate_by_token(id, key)
      end
    elsif guest_user? && cookies[:user]
        logger.info("auto_login: found user cookie, loading account")
        token = SecureToken.parse(User.to_s, cookies[:user])
        session['user'] = User.find(token.id)
    end
  end
  
end