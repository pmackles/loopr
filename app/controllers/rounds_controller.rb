class RoundsController < ApplicationController
  
  helper :round, :stats
  skip_before_filter :auto_login, :only => [:list, :summary, :rounds_with_summary]
  
  def compare
    round_ids = if params[:rounds].is_a?(Array)
      params[:rounds]
    elsif params[:rounds]
      params[:rounds].split(",")
    end

    @rounds = []
    if round_ids
      @rounds = Round.find(round_ids)
    end

    render :layout => :standardlayout
  end

  def summary
    @filter = RoundFilter.new(params[:filter])
    @summary = SqlRoundSummarizer.new(@filter).summary

    respond_to do |format|
      format.js do
        render :layout => false, :json => { :summary => @summary }.to_json
      end
    end   
  end

  def rounds_with_summary
    srs = SqlRoundSummarizer.new(RoundFilter.new(params[:filter] || {}))
    @rounds = srs.rounds
    @summary = srs.summary
    
    respond_to do |format|
      format.js do
        render :layout => false, :json => { :rounds => @rounds, :summary => @summary }.to_json
      end
    end   
  end

  def list
    logger.debug(params.inspect)
    rounds = if params[:courses]
      Round.list(:conditions => ['course_id in (?)', params[:courses].split(",")])
    elsif params[:users]
      Round.list(:conditions => ["user_id in (?)", params[:users].split(",")])
    else
      Round.list
    end
    render :partial => 'list', :object => rounds
  end
    
  def index
    @rounds = Round.paginate(
      :order => "date_played desc", 
      :page => params[:page] || 1, 
      :per_page => 40,
      :finder => :list
    )
    render :layout => :standardlayout
  end

end
