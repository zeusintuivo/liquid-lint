# frozen_string_literal: true

module LiquidLint::Matcher
  # Wraps a matcher, taking on the behavior of the wrapped matcher but storing
  # the value that matched so it can be referred to later.
  class Capture < Base
    # @return [LiquidLint::Matcher::Base] matcher that this capture wraps
    attr_accessor :matcher

    # @return [Object] value that was captured
    attr_accessor :value

    # Creates a capture that wraps that given matcher.
    #
    # @param matcher [LiquidLint::Matcher::Base]
    # @return [LiquidLint::Matcher::Capture]
    def self.from_matcher(matcher)
      new.tap do |cap_matcher|
        cap_matcher.matcher = matcher
      end
    end

    # @see {LiquidLint::Matcher::Base#match?}
    def match?(object)
      if result = @matcher.match?(object)
        @value = object
      end

      result
    end
  end
end
