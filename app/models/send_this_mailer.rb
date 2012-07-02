class SendThisMailer < ActionMailer::Base

  def course(to, from, msg, course, base_url, sent_at = Time.now)
    @subject    = "#{course.name}"
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @body = {
      :course => course,
      :base_url => base_url,
      :msg => msg,
      :from => from
    }
#    @headers    = {}
  end

  def round(to, from, msg, round, base_url, sent_at = Time.now)
    @subject    = "Scorecard from #{round.course.name} (#{round.date_played.to_formatted_s(:mmddyyyy)})"
    @recipients = to
    @from       = "#{from} via LOOPR.com <#{from}>"
    @sent_on    = sent_at
    @body = {
      :round => round,
      :base_url => base_url,
      :msg => msg,
      :from => from
    }
#    @headers    = {}
  end
  
  def outing(to, from, msg, outing, base_url, sent_at = Time.now)
    @subject    = "Scorecard from #{outing.course.name} (#{outing.date.to_formatted_s(:mmddyyyy)})"
    @recipients = to
    @from       = "#{from} via LOOPR.com <#{from}>"
    @sent_on    = sent_at
    @body = {
      :outing => outing,
      :base_url => base_url,
      :msg => msg,
      :from => from
    }
#    @headers    = {}
  end
  
end

