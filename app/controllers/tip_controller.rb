class TipController < ApplicationController

  before_filter :login_required, :except => [:list, :show, :index]
  
  def index
    list
    render :action => 'list'
  end

  def list
    @tip_pages, @tips = paginate :tips, :per_page => 10
  end

  def show
    @tip = Tip.find(params[:id])
  end

  def new
    @tip = Tip.new(:course_id => params[:course_id])
  end

  def create
    @tip = Tip.new(params[:tip])
    @tip.user_id = current_user.id

    if @tip.save
      render :text => { :saved => true }.to_json
    else
      render :text => { 
        :saved => false, 
        :errors => @tip.errors.full_messages 
      }.to_json
    end
  end

  def edit
    @tip = Tip.find(params[:id])
  end

  def update
    @tip = Tip.find(params[:id])
    if @tip.update_attributes(params[:tip])
      flash[:notice] = 'Tip was successfully updated.'
      redirect_to :action => 'show', :id => @tip
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tip.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
