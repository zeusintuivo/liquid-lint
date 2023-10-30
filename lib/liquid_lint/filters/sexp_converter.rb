# frozen_string_literal: true

module LiquidLint::Filters
  # Converts a Temple S-expression comprised of {Array}s into {LiquidLint::Sexp}s.
  #
  # These {LiquidLint::Sexp}s include additional helpers that makes working with
  # them more pleasant.
  class SexpConverter < Temple::Filter
    # Converts the given {Array} to a {LiquidLint::Sexp}.
    #
    # @param array_sexp [Array]
    # @return [LiquidLint::Sexp]
    def call(array_sexp)
      LiquidLint::Sexp.new(array_sexp)
    end
  end
end
