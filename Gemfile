# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 3.1"

# Core framework
gem "rails", "~> 7.2.3"

# Asset pipeline
gem "sprockets-rails"

# Database
gem "pg", "~> 1.1"

# Web server
gem "puma", ">= 5.0"

# JavaScript bundling (importmap — no Node required)
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# JSON API
gem "jbuilder"

# Authentication (has_secure_password)
gem "bcrypt", "~> 3.1"

# Bootstrap 5 + jQuery — Constitution Principle III (UX consistency)
gem "dartsass-sprockets"
gem "bootstrap", "~> 5.3"
gem "jquery-rails"

# Timezone data (Windows/JRuby)
gem "tzinfo-data", platforms: %i[windows jruby]

# Boot-time caching
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # TDD — Constitution Principle II
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "capybara", "~> 3.40"
  gem "shoulda-matchers", "~> 6.0"

  # Code coverage gate ≥80% — Constitution Principle II
  gem "simplecov", require: false

  # Code quality — Constitution Principle I
  gem "rubocop", "~> 1.86", require: false
  gem "rubocop-rails", "~> 2.25", require: false
  gem "rubocop-rspec", "~> 3.1", require: false
end

group :development do
  gem "web-console"
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end

group :test do
  gem "selenium-webdriver"
  gem "webdrivers", require: false
end
