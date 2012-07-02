class UserStatSummary < StatSummary

  belongs_to :user, :foreign_key => :entity_id
  
#  def filter
#    @filter ||= RoundFilter.new(:users => [entity_id],:time_period => 'max')
#  end
  
  def summarize_and_save

    ActiveRecord::Base.connection.update(
      "update stat_summaries ss left outer join " +
      "(select user_id, #{@@summary_sql} from rounds where user_id=#{entity_id} group by user_id) r on (ss.entity_id=r.user_id)" + 
      "set #{@@sql2} " +
      "where ss.type=\"UserStatSummary\" and ss.entity_id=#{entity_id}"
    )
  end
  
end