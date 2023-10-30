# frozen_string_literal: true

module LiquidLint
  # Generates a {LiquidLint::Sexp} suitable for consumption by the
  # {RubyExtractor}.
  #
  # This is mostly copied from Liquid::Engine, with some filters and generators
  # omitted.
  class RubyExtractEngine < Temple::Engine
    filter :Encoding
    filter :RemoveBOM

    # Parse into S-expression using Liquid parser
    use Liquid::Parser

    # Perform additional processing so extracting Ruby code in {RubyExtractor}
    # is easier. We don't do this for regular linters because some information
    # about the original syntax tree is lost in the process, but that doesn't
    # matter in this case.
    use Liquid::Embedded
    use Liquid::Interpolation
    use LiquidLint::Filters::SplatProcessor
    use Liquid::DoInserter
    use Liquid::EndInserter
    use LiquidLint::Filters::ControlProcessor
    use LiquidLint::Filters::AttributeProcessor
    filter :MultiFlattener
    filter :StaticMerger

    # Converts Array-based S-expressions into LiquidLint::Sexp objects, and gives
    # them line numbers so we can easily map from the Ruby source to the
    # original source
    use LiquidLint::Filters::SexpConverter
    use LiquidLint::Filters::InjectLineNumbers
  end
end
