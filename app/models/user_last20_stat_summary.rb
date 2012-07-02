class UserLast20StatSummary < StatSummary

  belongs_to :user, :foreign_key => :entity_id
  
  def summarize_and_save

    handicap_rounds = Round.find(
      :all, 
      :conditions => ['user_id=? and count_towards_handicap=1', entity_id], 
      :limit => 40, 
      :order => 'date_played desc'
    )
    
    handicap_index = if handicap_rounds.any?                          
      USGAHandicapper.new(handicap_rounds).handicap
    else
      nil
    end

    ActiveRecord::Base.connection.update(
      "update stat_summaries ss left outer join " +
      "(select user_id, #{@@summary_sql} from rounds, (select id from rounds where user_id=#{entity_id} order by date_played desc limit 20) t where user_id=#{entity_id} and t.id=rounds.id group by user_id) r on (ss.entity_id=r.user_id)" + 
      "set handicap = #{handicap_index || 'null'}, #{@@sql2} " +
      "where ss.type=\"UserLast20StatSummary\" and ss.entity_id=#{entity_id}"
    )
  end
  
end