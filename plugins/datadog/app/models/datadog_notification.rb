# frozen_string_literal: true
require 'faraday'
require 'digest/md5'

# Note: might be able to replace this with Samson.statsd.event
class DatadogNotification
  def initialize(deploy)
    @deploy = deploy
    @stage = @deploy.stage
  end

  def deliver(additional_tags: [], now: false)
    status =
      if @deploy.active?
        "info"
      elsif @deploy.succeeded?
        "success"
      else
        "error"
      end

    response = Faraday.post "https://api.datadoghq.com/api/v1/events?api_key=#{DatadogMonitor::API_KEY}" do |request|
      request.body = {
        title: @deploy.summary,
        text: "#{@deploy.user.email} deployed #{@deploy.short_reference} to #{@stage.name}",
        alert_type: status,
        source_type_name: "samson",
        date_happened: now ? Time.now.to_i : @deploy.updated_at.to_i,
        tags: @stage.datadog_tags_as_array + ["deploy", *additional_tags]
      }.to_json
    end

    unless response.success?
      Rails.logger.info "Failed to send Datadog notification: #{response.status}"
    end
  end
end
