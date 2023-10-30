# frozen_string_literal: true

module LiquidLint::Matcher
  # Will match anything, acting as a wildcard.
  class Anything < Base
    # @see {LiquidLint::Matcher::Base#match?}
    def match?(*)
      true
    end
  end
end
