# frozen_string_literal: true

require 'logger'
require 'thor'
require_relative 'lib/fetcher'
require_relative 'lib/html_formatter'
require_relative 'lib/tester'

class MyCLI < Thor
  desc 'test', 'test'
  option :seed_urls, type: :array, default: []
  option :allowed_url_patterns, type: :array, default: []
  option :interval, type: :numeric, default: 1
  option :timeout, type: :numeric, default: 10
  option :user_agent, type: :string, default: 'webtester-crawler-bot'
  option :log_level, type: :string, default: 'info'
  def test
    logger = Logger.new(STDERR)
    logger.level = options[:log_level]
    fetcher = Fetcher.new(default_interval_sec: options[:interval], user_agent: options[:user_agent])
    regexps = options[:allowed_url_patterns].map do |pattern|
      Regexp.new(pattern)
    end
    is_url_allowed = lambda do |url|
      regexps.any? do |regex|
        regex.match(url)
      end
    end
    tester = Tester.new(
      fetcher: fetcher,
      seed_urls: options[:seed_urls],
      is_url_allowed: is_url_allowed,
      timeout_sec: options[:timeout],
      logger: logger
    )
    results = tester.run
    formatter = HtmlFormatter.new
    puts formatter.format(results)
  end
end

MyCLI.start(ARGV)
