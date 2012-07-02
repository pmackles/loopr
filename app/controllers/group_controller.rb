
class GroupController < ApplicationController
  layout "group"
#  model :leaderboard

  helper :scorecard, :stats, :rounds

  before_filter :login_required, :only => [:new, :create]
  
  before_filter :membership_required, 
      :only => [:invite, :settings, :edit_profile, :edit_icon, :edit_membership]
  
  def membership_required
    @group = Group.find(params[:id])
    unless logged_in? && @group.authorized?(current_user)
      redirect_to :action => 'show', :id => @group
      return false
    end
  end
  
  def stats
    headers["Status"] = "301 Moved Permanently"
    redirect_to(group_stats_url(:id => params[:id]))
  end
  
  def stats_laggards
    headers["Status"] = "301 Moved Permanently"
    redirect_to(group_stats_url(:id => params[:id]))
  end
  
  def rounds_summary
    @group = Group.find(params[:id])
    @filter = RoundFilter.new(params_filter_with_defaults)
    summarizer = SqlRoundSummarizer.new(@filter)
    @summary = summarizer.summary
  end
    
  def show
    @group = Group.find(params[:id])    
    @outings = @group.rounds.group_by do |r| 
      Outing.new(r.date_played, r.course_id, r.course_name, r.total_holes)
    end
  end

  def new
    @group = Group.new
    render :layout => "standard"
  end

  def rounds
    @group = Group.find(params[:id])
    @round_table = RoundTable.new(@group.members.collect { |m| m.id }, params)
  end
  
#  def outings
#    @group = Group.find(params[:id])
#
#    page = params[:page] || 1
#    @rounds = Round.paginate_by_user_id(
#          @group.members.collect { |m| m.id }, 
#          :page => page
#    )
#    @outings = @rounds.group_by { |r| Outing.new(r.date_played, r.course, r.total_holes) }
#  end
  
  def members
    @group = Group.find(params[:id])
    @admins, @members = @group.members.partition { |m| m.group_role != "0" }
  end

  def iframe
    outing
    render :layout => false
  end
    
  def outing
    headers["Status"] = "301 Moved Permanently"
    redirect_to(:controller => :round, :action => :compare, :rounds => params[:rounds])
  end

  def invite

    if params[:commit].nil?
      @invite = GroupInvite.new
      @invite.body = 
        "I wanted to invite you to join a cool group on Loopr! " +
        "It's called #{@group.name} and it's more fun then a bag of chips!"
      return
    end

    @invite = GroupInvite.new(params[:invite])
    @invite.user = current_user
    @invite.group = @group
    @invite.url = url_for :controller => '/'
    
    return unless @invite.save
    render :action => :invite_success
  end
  
  def create
    @group = Group.new(params[:group])
    @group.memberships << Membership.new(:user => current_user, 
                                         :role => Group::CREATE_ROLE)   
    if @group.save
      flash[:notice] = 'Your new group has been created.'
      redirect_to :action => 'show', :id => @group
    else
      render :action => 'new', :layout => "standard"
    end
  end

  def settings
  end

  def edit_profile
    return unless request.post? && save    
    render :action => :edit_profile_success
  end
  
  def edit_icon
    return unless request.post? && save
    render :action => :edit_icon_success
  end

  def edit_membership
    return unless request.post? && save
    render :action => :edit_membership_success
  end
  
  protected

  def save
    @group.attributes = params[:group]
  
    if params[:membership]
      @group.memberships.each { |m|
        unless m.role == Group::CREATE_ROLE
          m.attributes = params[:membership][m.id.to_s]
        end
      }
    end
    
    if params[:file]
      data_file = params[:file]
      path = "/images/upload/group/icon/#{@group.id}.gif"
      iconizer = IconMaker.new(data_file)
      unless iconizer.save_to_file(path)
        @group.errors.add_to_base("upload failed")
        return false
      end
    
      @group.icon_url = path
    end
    
    begin
      Group.transaction do
        @group.save!
        @group.memberships.each { |m|
          m.save!
        }      
      end
    rescue ActiveRecord::RecordInvalid => invalid
      return false
    end
    
    true
  end

  private
  
  def params_filter_with_defaults
    (params[:filter] || {}).reverse_merge(HashWithIndifferentAccess.new(:users => @group.members))
  end
  
end
