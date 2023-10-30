# frozen_string_literal: true

module LiquidLint::Matcher
  # Does not match anything.
  #
  # This is used in specs.
  class Nothing < Base
    # @see {LiquidLint::Matcher::Base#match?}
    def match?(*)
      false
    end
  end
end
