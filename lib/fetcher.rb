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
    response = @connection.get do |req|
      req.url url
    end
    @last_fetched_at = Time.now
    response
  end
end
