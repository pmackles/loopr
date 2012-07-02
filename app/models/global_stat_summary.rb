class GlobalStatSummary < StatSummary
  
#  has_many :recent_rounds, 
#      :class_name => 'Round',
#      :finder_sql => 'select r.* from stat_summaries, rounds r ' +
#                     'where type="UserStatSummary" and ' +
#                     'last_round = r.id ' +
#                     'order by r.created_on desc limit 8';
#            
#  # exclude sample users
#  has_many :low_rounds, 
#      :class_name => 'Round',
#      :finder_sql => 'select r.* from stat_summaries, rounds r ' +
#                     'where type="UserStatSummary" and ' +
#                     'low_round = r.id and ' +
#                     'entity_id not in (2, 3, 4) and ' +
#                     'rounds_played > 2 ' + 
#                     'order by r.created_on desc limit 8';
#
#  def filter
#    @filter ||= RoundFilter.new({:time_period => 'max'})
#  end 

  def summarize_and_save
    ActiveRecord::Base.connection.update(
      "update stat_summaries ss left outer join " +
      "(select 0 user_id, #{@@summary_sql} from rounds) r on (ss.entity_id=r.user_id) " + 
      "set #{@@sql2} " +
      "where ss.type=\"GlobalStatSummary\" and ss.entity_id=0"
    )
  end
    
  def self.compile_global_stats  
    stats = GlobalStatSummary.find_or_create_by_entity_id(0)    
    stats.summarize_and_save
  end
    
end