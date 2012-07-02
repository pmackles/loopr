
class AccountController < ApplicationController
  layout "standard"
  helper :user
  
  before_filter :login_required, 
    :except => [:login, :forgot_password, :signup, 
                :logout, :account_needed, :verify]
  skip_before_filter :auto_login, :only => [:edit_profile]
  
  def account_needed
    render(:layout => 'login')
  end
  
  def edit_email
    @user = User.find(current_user.id)

    if request.post?
      @user.email = params[:user][:email]  
      if @user.save
        flash[:notice] = 'Email address updated.'
        redirect_to :action => 'blog', :controller => 'user', :id => @user
        return
      end
    end
  end

#  def edit_courses
#    @user = User.find(current_user.id)
#    render :layout => :userlayout
#  end
    
  def edit_profile
    @user = User.find(current_user.id)

    if request.post? and params[:commit]
      @user.attributes = params[:user]
  
      if @user.save
        render :json => { :saved => true }.to_json
      else
        render :json => { :saved => false, :errors => @user.errors.full_messages}.to_json
      end
      return
    end
    render :layout => :userlayout
  end

  def edit_icon
    @user = User.find(current_user.id)

    if request.post?
      file = params[:file]
      path = "/images/upload/user/icon/#{current_user.id}.gif"
      iconizer = IconMaker.new(file)
      if iconizer.save_to_file(path)
        @user.icon_url = path
        @user.save
        flash[:notice] = 'Upload complete.'
        redirect_to :action => 'blog', :controller => 'user', :id => @user
        return
      else
        @user.errors.add_to_base("Problems uploading icon")
      end
  
    end
    
  end
  
  def settings
    @user = User.find(current_user.id)
  end
    
  def reset_password
    return if generate_filled_in('standard')
    params['user'].delete('form')
    
    if update_password
      flash[:notice] = 'Password reset.'
      redirect_to :action => 'blog', :controller => 'user', :id => @user
    else
      render(:layout => 'standard')
    end
  end
  
  def change_password
    @user = User.find(current_user.id)

    return if generate_filled_in
    params['user'].delete('form')

    if update_password
      flash[:notice] = 'Password changed.'
      redirect_to :action => 'blog', :controller => 'user', :id => @user
      return
    end
  end
  
  def login
    
    return if generate_blank('login')
    @user = User.authenticate(params['user']['login'], params['user']['password'])
    if @user
      session['user'] = @user
      remember_user(@user)
 #     flash['notice'] = l(:user_login_succeeded)
 #     redirect_back_or_default(:action => 'index', :controller => 'main')
      if params[:path]
        redirect_to params[:path]
      else
        redirect_to :controller => '/'
      end
      return
    else
      @login = params['user']['login']
      @error = l(:user_login_failed)
    end
    
    render(:layout => 'login')
  end

  def logout
    reset_session
    forget_user
    if params[:path]
      redirect_to params[:path]
    else
      redirect_to :controller => '/'
    end
  end
  
  def signup
    return if generate_blank('login')
    params['user'].delete('form')
    @user = User.new(params['user'])

    # don't require clc
    # @user.verified = 1
    
    begin
      User.transaction do
        @user.new_password = true
        if @user.save
          key = @user.generate_security_token
          confirm_url = url_for(:action => 'verify')
          confirm_url += "?id=#{@user.id}&key=#{key}"
          home_url = url_for :controller => @user.login, :only_path => false
          UserNotify.deliver_signup(@user, params['user']['password'], confirm_url, home_url)
          flash['notice'] = l(:user_signup_succeeded)
        else
          logger.debug("save failed #{@user.errors.empty?}")
          raise ActiveRecord::RecordInvalid, "invalid"
        end
      end
      # log the user in right away
      session['user'] = @user  
      remember_user(@user) 
      redirect_back_or_default(:action => 'blog', :controller => 'user', :id => @user)
      return
    rescue
      logger.debug("rescuing #{@user.errors.empty?}")
      flash.now['message'] = l(:user_confirmation_email_error)
    end
    
    logger.debug("rendering #{@user.errors.empty?}")
    render(:layout => 'login')
  end  

  def forgot_password

    # Render on :get and render
    return if generate_blank('login')

    # Handle the :post
    if params['user']['login'].empty?
      @error = "please enter your username"
    elsif (user = User.find_by_login(params['user']['login'])).nil?
      @error = l("sorry, no account with that name", "#{params['user']['login']}")
    else
      begin
        User.transaction(user) do
          key = user.generate_security_token
          url = url_for(:action => 'reset_password')
          url += "?user[id]=#{user.id}&key=#{key}"
          UserNotify.deliver_forgot_password(user, url)
#          @error = l(:user_forgotten_password_emailed, "#{params['user']['login']}")
#          unless user?
#            redirect_to :action => 'login'
#            return
#          end
#          redirect_back_or_default :action => 'welcome'
        end
      rescue
        @error = l(:user_forgotten_password_email_error, "#{params['user']['login']}")
      end
    end
    
    if @error
      render(:layout => 'login')
    else
      render(:action => 'forgot_password_confirm', :layout => 'login')
    end
  end


  def welcome
    render :layout => 'standard'
  end

  def verify
    id = params['id']
    key = params['key']
    if id.nil? || key.nil?
      render :layout => 'login', :action => 'verify_failed'
      return
    end
    
    u = User.authenticate_by_token(id, key)
    
    if u.nil?
      render :layout => 'login', :action => 'verify_failed'
      return
    end
    
    session['user'] = u
    render :layout => 'login'
  end
  
  protected
  
  def update_password
    begin
      User.transaction do
        @user.change_password(params['user']['password'], params['user']['password_confirmation'])
        unless @user.save
          raise ActiveRecord::RecordInvalid, "invalid"
        end
      end
    rescue
      flash.now['message'] = l(:user_change_password_email_error)
      return false
    end
    
    return true
  end
  
  def destroy(user)
    UserNotify.deliver_delete(user)
    flash['notice'] = l(:user_delete_finished, "#{user['login']}")
    user.destroy()
  end

  def protect?(action)
    if ['login', 'signup', 'forgot_password'].include?(action)
      return false
    else
      return true
    end
  end
    
  # Generate a template user for certain actions on get
  def generate_blank(layout = nil)
    case @request.method
    when :get
      @user = User.new
      if layout
        render :layout => layout
      else
        render
      end
      return true
    end
    return false
  end

  def generate_filled_in(layout = nil)
    @user = User.find(session['user'].id)
    case @request.method
    when :get
      if layout
        render :layout => layout
      else
        render
      end
      return true
    end
    return false
  end
      
end
