# frozen_string_literal: true

register_test(
  test: lambda do |result|
    if result[:status] >= 400 && result[:status] < 500
      {
        error: 'Not Found'
      }
    end
  end
)
