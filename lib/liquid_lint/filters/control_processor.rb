# frozen_string_literal: true

module LiquidLint::Filters
  # A dumbed-down version of {Liquid::Controls} which doesn't introduce temporary
  # variables and other cruft (which in the context of extracting Ruby code,
  # results in a lot of weird cops reported by RuboCop).
  class ControlProcessor < Liquid::Filter
    BLOCK_RE = /\A(if|unless)\b|\bdo\s*(\|[^|]*\|)?\s*$/

    # Handle control expression `[:liquid, :control, code, content]`
    #
    # @param code [String]
    # @param content [Array]
    def on_liquid_control(code, content)
      [:multi,
        [:code, code],
        compile(content)]
    end

    # Handle output expression `[:liquid, :output, escape, code, content]`
    #
    # @param _escape [Boolean]
    # @param code [String]
    # @param content [Array]
    # @return [Array
    def on_liquid_output(_escape, code, content)
      if code[BLOCK_RE]
        [:multi,
          [:code, code, compile(content)],
          [:code, 'end']]
      else
        [:multi, [:dynamic, code], compile(content)]
      end
    end

    # Handle text expression `[:liquid, :text, type, content]`
    #
    # @param _type [Symbol]
    # @param content [Array]
    # @return [Array]
    def on_liquid_text(_type, content)
      # Ensures :newline expressions from static output are still represented in
      # the final expression
      compile(content)
    end
  end
end
