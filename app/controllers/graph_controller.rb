#---
# Excerpted from "Rails Recipes"
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/fr_rr for more book information.
#---
class GraphController < ApplicationController

require 'gruff'

#  STATS_DIRECTORIES = [
#    %w(Helpers            app/helpers), 
#    %w(Controllers        app/controllers), 
#    %w(APIs               app/apis),
#    %w(Components         components),
#    %w(Functional\ tests  test/functional),
#    %w(Models             app/models),
#    %w(Unit\ tests        test/unit),
#    %w(Libraries          lib/),
#    %w(Integration\ tests test/integration)
#  ].collect { |name, dir| 
#      [ name, "#{RAILS_ROOT}/#{dir}" ] 
#    }.select { |name, dir| 
#      File.directory?(dir) 
#    }
#
#  def stats2
#    user = current_user
#    code_stats = CodeStatistics.new(*STATS_DIRECTORIES)
#    statistics = code_stats.instance_variable_get(:@statistics)
#    g = Gruff::Pie.new(800)
#    g.font = "/Library/Fonts/Arial"
#    g.title = "Code Stats"
#    g.theme_37signals
#    g.legend_font_size = 10
#    0xFDD84E.step(0xFF0000, 1500) do |num|
#      g.colors << "#%x"  % num
#    end
#    statistics.each do |key, values|
#      g.data(key, [values["codelines"]])
#    end
#
#    send_data(g.to_blob, 
#                :disposition => 'inline', 
#                :type => 'image/png', 
#                :filename => "code_stats.png")
#  end
  
  def scores
    user = User.find(params[:id])
#    code_stats = CodeStatistics.new(*STATS_DIRECTORIES)
#    statistics = code_stats.instance_variable_get(:@statistics)
    g = Gruff::Line.new("600x200")
    g.font = "/Library/Fonts/Arial"
#    g.hide_legend = true
    g.title = "Scoring"
#    g.theme_37signals
#    g.marker_font_size = 60
#    0xFDD84E.step(0xFF0000, 1500) do |num|
#      g.colors << "#%x"  % num
#    end
#    statistics.each do |key, values|
#      g.data(key, [values["codelines"]])
#    end

    rounds = user.full_rounds
    scores = rounds.collect { |r| r.total_score }
    g.data("average", scores)
    rounds.each_with_index { |r, i|
      g.labels[i] = r.date_played.to_s
    }
    
    send_data(g.to_blob, 
                :disposition => 'inline', 
                :type => 'image/png', 
                :filename => "code_stats.png")
  end
  
  def stats
    user = current_user
#    code_stats = CodeStatistics.new(*STATS_DIRECTORIES)
#    statistics = code_stats.instance_variable_get(:@statistics)
    g = Gruff::Mini::Pie.new(150)
    g.font = "/Library/Fonts/Arial"
#    g.hide_legend = true
    g.hide_title = true
    g.title = "Code Stats"
#    g.theme_37signals
#    g.marker_font_size = 60
#    0xFDD84E.step(0xFF0000, 1500) do |num|
#      g.colors << "#%x"  % num
#    end
#    statistics.each do |key, values|
#      g.data(key, [values["codelines"]])
#    end
    g.data("Bogies", [user.stats.bogey_percentage]) 
    g.data("Pars", [user.stats.par_percentage])
    g.data("Birdies", [user.stats.birdie_percentage])
    g.data("Other", [user.stats.other_percentage])
    send_data(g.to_blob, 
                :disposition => 'inline', 
                :type => 'image/png', 
                :filename => "code_stats.png")
  end

end
