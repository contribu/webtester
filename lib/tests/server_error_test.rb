# frozen_string_literal: true

register_test(
  test: lambda do |result|
    if result[:status] >= 500 && result[:status] < 600
      {
        error: 'Server Error'
      }
    end
  end
)
