# frozen_string_literal: true

module LiquidLint::Filters
  # A dumbed-down version of {Liquid::CodeAttributes} which doesn't introduce any
  # temporary variables or other cruft.
  class AttributeProcessor < Liquid::Filter
    define_options :merge_attrs

    # Handle attributes expression `[:html, :attrs, *attrs]`
    #
    # @param attrs [Array]
    # @return [Array]
    def on_html_attrs(*attrs)
      [:multi, *attrs.map { |a| compile(a) }]
    end

    # Handle attribute expression `[:html, :attr, name, value]`
    #
    # @param name [String] name of the attribute
    # @param value [Array] Sexp representing the value
    def on_html_attr(name, value)
      if value[0] == :liquid && value[1] == :attrvalue
        code = value[3]
        [:code, code]
      else
        @attr = name
        super
      end
    end
  end
end
