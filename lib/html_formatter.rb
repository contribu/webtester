# frozen_string_literal: true

require 'html/table'

class HtmlFormatter
  def format(results)
    table = HTML::Table.new
    results.each do |result|
      table.push HTML::Table::Row.new { |row|
        row.content = [
          result[:url],
          result[:status],
          result[:size],
          # result[:to_urls].join(','),
          result[:from_urls].join(',')
        ]
      }
    end

    <<~HTML
      <html>
      <head></head>
      <body>
        #{table.html}
      </body>
      </html>
    HTML
  end
end
