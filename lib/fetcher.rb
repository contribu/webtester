# frozen_string_literal: true

require 'faraday'
require 'uri'

class Fetcher
  def initialize(default_interval_sec:, user_agent:)
    @connection = Faraday.new do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.headers['Accept-Charset'] = 'UTF-8'
      faraday.headers['User-Agent'] = user_agent
    end
    @default_interval_sec = default_interval_sec
    @last_fetched_at = Time.now
  end

  def fetch(url)
    sleep([@last_fetched_at + @default_interval_sec - Time.now, 0].max)
    fetch_started_at = Time.now
    response = @connection.get do |req|
      req.url url
    end
    total_time = Time.now - fetch_started_at
    @last_fetched_at = Time.now
    {
      total_time: total_time,
      raw_response: response
    }
  end
end
