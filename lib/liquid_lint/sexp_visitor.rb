# frozen_string_literal: true

module LiquidLint
  # Provides an interface which when included allows a class to visit nodes in
  # the Sexp of a Liquid document.
  module SexpVisitor
    # Traverse the Sexp looking for matches with registered patterns, firing
    # callbacks for all matches.
    #
    # @param sexp [LiquidLint::Sexp]
    def trigger_pattern_callbacks(sexp)
      return if on_start(sexp) == :stop

      traverse sexp
    end

    # Traverse the given Sexp, firing callbacks if they are defined.
    #
    # @param sexp [LiquidLint::Sexp]
    def traverse(sexp)
      patterns.each do |pattern|
        next unless sexp.match?(pattern.sexp)

        result = method(pattern.callback_method_name).call(sexp)

        # Returning :stop indicates we should stop searching this Sexp
        # (i.e. stop descending this branch of depth-first search).
        # The `return` here is very intentional.
        return if result == :stop # rubocop:disable Lint/NonLocalExitFromIterator
      end

      # Continue traversing children by default (match blocks can return `:stop`
      # to not continue).
      traverse_children(sexp)
    end

    # Traverse the children of this {Sexp}.
    #
    # @param sexp [LiquidLint::Sexp]
    def traverse_children(sexp)
      sexp.each do |nested_sexp|
        traverse nested_sexp if nested_sexp.is_a?(Sexp)
      end
    end

    # Returns the map of capture names to captured values.
    #
    # @return [Hash, CaptureMap]
    def captures
      self.class.captures || {}
    end

    # Returns the list of registered Sexp patterns.
    #
    # @return [Array<LiquidLint::SexpVisitor::SexpPattern>]
    def patterns
      self.class.patterns || []
    end

    # Executed before searching for any pattern matches.
    #
    # @param sexp [LiquidLint::Sexp] see {SexpVisitor::DSL.on_start}
    # @return [Symbol] see {SexpVisitor::DSL.on_start}
    def on_start(*)
      # Overidden by DSL.on_start
    end

    # Mapping of Sexp pattern to callback method name.
    #
    # @attr_reader sexp [Array] S-expression pattern that when matched triggers the
    #     callback
    # @attr_reader callback_method_name [Symbol] name of the method to call when pattern is matched
    SexpPattern = Struct.new(:sexp, :callback_method_name)
    private_constant :SexpPattern

    # Exposes a convenient Domain-specific Language (DSL) that makes declaring
    # Sexp match patterns very easy.
    #
    # Include them with `extend LiquidLint::SexpVisitor::DSL`
    module DSL
      # Registered patterns that this visitor will look for when traversing the
      # {LiquidLint::Sexp}.
      attr_reader :patterns

      # @return [Hash] map of capture names to captured values
      attr_reader :captures

      # DSL helper that defines a sexp pattern and block that will be executed if
      # the given pattern is found.
      #
      # @param sexp_pattern [Sexp]
      # @yield block to execute when the specified pattern is matched
      # @yieldparam sexp [LiquidLint::Sexp] Sexp that matched the pattern
      # @yieldreturn [LiquidLint::Sexp,Symbol,void]
      #   If a Sexp is returned, indicates that traversal should jump directly
      #   to that Sexp.
      #   If `:stop` is returned, halts further traversal down this branch
      #   (i.e. stops recursing, but traversal at higher levels will continue).
      #   Otherwise traversal will continue as normal.
      def on(sexp_pattern, &block)
        # TODO: Index Sexps on creation so we can quickly jump to potential
        # matches instead of checking array.
        @patterns ||= []
        @pattern_number ||= 1

        # Use a monotonically increasing number to identify the method so that in
        # debugging we can simply look at the nth defintion in the class.
        unique_method_name = :"on_pattern_#{@pattern_number}"
        define_method(unique_method_name, block)

        @pattern_number += 1
        @patterns << SexpPattern.new(sexp_pattern, unique_method_name)
      end

      # Define a block of code to run before checking for any pattern matches.
      #
      # @yield block to execute
      # @yieldparam sexp [LiquidLint::Sexp] the root Sexp
      # @yieldreturn [Symbol] if `:stop`, indicates that no further processing
      #   should occur
      def on_start(&block)
        define_method(:on_start, block)
      end

      # Represents a pattern that matches anything.
      #
      # @return [LiquidLint::Matcher::Anything]
      def anything
        LiquidLint::Matcher::Anything.new
      end

      # Represents a pattern that matches the specified matcher, storing the
      # matched value in the captures list under the given name.
      #
      # @param capture_name [Symbol]
      # @param matcher [LiquidLint::Matcher::Base]
      # @return [LiquidLint::Matcher::Capture]
      def capture(capture_name, matcher)
        @captures ||= LiquidLint::CaptureMap.new

        @captures[capture_name] =
          LiquidLint::Matcher::Capture.from_matcher(matcher)
      end
    end
  end
end
