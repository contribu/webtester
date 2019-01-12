# frozen_string_literal: true

require 'faraday'
require 'htmlentities'
require 'uri'

class Tester
  def initialize(fetcher:, seed_urls:, is_url_allowed:, logger:, timeout_sec:)
    @fetcher = fetcher
    @seed_urls = seed_urls
    @is_url_allowed = is_url_allowed
    @logger = logger
    @timeout_sec = timeout_sec
  end

  def run
    started_at = Time.now

    remaining_urls = @seed_urls.select { |url| @is_url_allowed.call(url) }.uniq.sort
    results = {}
    until remaining_urls.empty? || Time.now > started_at + @timeout_sec
      url = remaining_urls.first
      @logger.info(url)
      response = @fetcher.fetch(url)
      link_urls = if /text/i.match?(response[:raw_response]['Content-Type'])
                    extract_urls(response[:raw_response].body.force_encoding('utf-8').scrub, page_url: url)
                  else
                    []
                  end

      results[url] = {
        url: url,
        size: response[:raw_response].body.bytesize,
        status: response[:raw_response].status,
        total_time: (response[:total_time] * 1000).round,
        to_urls: link_urls,
        from_urls: []
      }
      remaining_urls = remaining_urls + link_urls - results.keys
      remaining_urls = remaining_urls.select { |url| @is_url_allowed.call(url) }.uniq.sort
    end
    results.each do |from_url, result|
      result[:to_urls].each do |to_url|
        results[to_url][:from_urls] << from_url if results[to_url]
      end
    end
    results.each do |_from_url, result|
      result[:from_urls] = result[:from_urls].uniq.sort
    end
    results.sort.to_h.values
  end

  def extract_urls(text, page_url:)
    decoded_text = HTMLEntities.new.decode(text)
    [text, decoded_text].map do |cont|
      cont.scan(url_regex).map do |match|
        url = match[0]
        begin
          @logger.debug("#{page_url}, #{url}")
          URI.join(page_url, url).to_s # relative to absolute
        rescue URI::InvalidURIError
          nil
        end
      end
    end.flatten.compact.uniq.sort
  end

  private

  def url_regex
    %r{['"]((https://|//|/)[\w\-./?%&=]+)['"]}
  end
end
