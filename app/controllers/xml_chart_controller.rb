class XmlChartController < ApplicationController

  def foo
    @user = User.find(params[:id])
    render :layout => false
  end

  def gir
    @user = User.find(params[:id])
    render :layout => false
  end
    
  def blah
    @user = User.find(params[:id])
#    @averages = @user.monthly_scoring_average

    rounds = @user.full_rounds
    @putting = rounds.collect { |r| r.putting_average }
    @data3 = rounds.collect { |r| r.par3_average }
    @data4 = rounds.collect { |r| r.par4_average }
    @data5 = rounds.collect { |r| r.par5_average }
    
    @labels = Array.new
    rounds.each_with_index { |r, i|
      @labels <<  r.date_played.to_s
    }
        
    render :layout => false
  end
 
  def x
    @user = User.find(params[:id])
#    @averages = @user.monthly_scoring_average

    rounds = @user.rounds.last(20)
    @data = rounds.collect { |r| r.total_score }

    @labels = Array.new
    rounds.each_with_index { |r, i|
      @labels <<  "#{r.date_played.to_formatted_s(:mmddyy)} #{r.course.short_name[0..10]}..."
    }
    
    render :layout => false
  end

  def y
    @user = User.find(params[:id])
#    @averages = @user.monthly_scoring_average

    rounds = @user.rounds.last(20)
    @data = rounds.collect { |r| r.putting_average }

    @labels = Array.new
    rounds.each_with_index { |r, i|
      @labels <<  "#{r.date_played.to_formatted_s(:mmddyy)} #{r.course.short_name[0..10]}..."
    }
    
    render :layout => false
  end
    
  def scoring
    @user = User.find(params[:id])
#    @averages = @user.monthly_scoring_average

    rounds = @user.rounds.last(20)
    @data = rounds.collect { |r| r.total_score }

    @labels = Array.new
    rounds.each_with_index { |r, i|
      @labels <<  r.date_played.to_s
    }

        
#    @labels = Array.new
#    now = DateTime.now
#    for i in 0..5
#      dt = now << (5 - i)
#      @labels[i] = dt.strftime("%Y-%m")
#    end  
       
#    @data = Hash.new
#    @averages.each { |r| @data[r.month] = r.avg }
#    
#    last = nil
#    for label in @labels
#	 if @data[label].nil?
#		  @data[label] = last
#	 else
#		  last = @data[label]
#     end
#    end
			
    render :layout => false
  end
end
