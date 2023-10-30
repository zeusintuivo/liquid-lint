# frozen_string_literal: true

module LiquidLint
  # Searches for control statements with only comments.
  class Linter::CommentControlStatement < Linter
    include LinterRegistry

    on [:liquid, :control] do |sexp|
      _, _, code = sexp
      next unless code[/\A\s*#/]

      comment = code[/\A\s*#(.*\z)/, 1]

      next if comment =~ /^\s*rubocop:\w+/
      next if comment =~ /^\s*Template Dependency:/

      report_lint(sexp,
                  "Liquid code comments (`/#{comment}`) are preferred over " \
                  "control statement comments (`-##{comment}`)")
    end
  end
end
