# frozen_string_literal: true

module LiquidLint::Filters
  # Traverses a Temple S-expression (that has already been converted to
  # {LiquidLint::Sexp} instances) and annotates them with line numbers.
  #
  # This is a hack that allows us to access line information directly from the
  # S-expressions, which makes a lot of other tasks easier.
  class InjectLineNumbers < Temple::Filter
    # {Sexp} representing a newline.
    NEWLINE_SEXP = LiquidLint::Sexp.new([:newline])

    # Annotates the given {LiquidLint::Sexp} with line number information.
    #
    # @param sexp [LiquidLint::Sexp]
    # @return [LiquidLint::Sexp]
    def call(sexp)
      @line_number = 1
      traverse(sexp)
      sexp
    end

    private

    # Traverses an {Sexp}, annotating it with line numbers.
    #
    # @param sexp [LiquidLint::Sexp]
    def traverse(sexp)
      sexp.line = @line_number

      case sexp
      when LiquidLint::Atom
        @line_number += sexp.strip.count("\n") if sexp.respond_to?(:count)
      when NEWLINE_SEXP
        @line_number += 1
      else
        sexp.each do |nested_sexp|
          traverse(nested_sexp)
        end
      end
    end
  end
end
