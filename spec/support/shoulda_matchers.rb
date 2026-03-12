# frozen_string_literal: true

# Configure shoulda-matchers to work with RSpec + Rails
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
