# frozen_string_literal: true

module LiquidLint::Filters
  # A dumbed-down version of {Liquid::Splat::Filter} which doesn't introduced
  # temporary variables or other cruft.
  class SplatProcessor < Liquid::Filter
    # Handle liquid splat expressions `[:liquid, :splat, code]`
    #
    # @param code [String]
    # @return [Array]
    def on_liquid_splat(code)
      [:code, code]
    end
  end
end
