# frozen_string_literal: true

# Global application constants.
module LiquidLint
  HOME = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze
  APP_NAME = 'liquid-lint'

  REPO_URL = 'https://github.com/zeusintuivo/liquid-lint'
  BUG_REPORT_URL = "#{REPO_URL}/issues"
end
