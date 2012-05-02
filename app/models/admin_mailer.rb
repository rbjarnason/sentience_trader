# encoding: UTF-8

class AdminMailer < ActionMailer::Base
  def critical_error(subject, body)
    @subject       = "CRITICAL: #{subject} (#{RAILS_ENV})"
    @recipients    = 'robofly@gmail.com,robert@streamburst.co.uk'
    @from          = 'computer@streamburst.tv'
    @body["text"] = body
    @sent_on    = Time.now
  end

  def report(subject, body)
    @subject       = "SentienceTrader Report: #{subject} (#{RAILS_ENV})"
    @recipients    = 'robofly@gmail.com,robert@streamburst.co.uk'
    @from          = 'computer@sentiencetrader.com'
    @body["text"] = body
    @sent_on    = Time.now
  end
end
