# frozen_string_literal: true

require 'erb'

class HtmlFormatter
  def format(results)
    erb = ERB.new(File.read("#{__dir__}/html_template.html.erb"))
    erb.result(binding)
  end
end
