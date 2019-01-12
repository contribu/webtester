# frozen_string_literal: true

require 'erb'

class HtmlFormatter
  def format(results)
    error_results = results.select { |result| !result[:errors].empty? }

    erb = ERB.new(File.read("#{__dir__}/html_template.html.erb"))
    erb.result(binding)
  end
end
