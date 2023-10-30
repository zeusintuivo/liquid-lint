# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Linter::CommentControlStatement do
  include_context 'linter'

  context 'when a control statement contains code' do
    let(:liquid) { '- some_code' }

    it { should_not report_lint }
  end

  context 'when a control statement contains only a comment' do
    let(:liquid) { <<-LIQUID }
      -# A comment
      - # Another comment testing leading whitespace
    LIQUID

    it { should report_lint line: 1 }
    it { should report_lint line: 2 }
  end

  context 'when a control statement contains a RuboCop directive' do
    let(:liquid) { <<-LIQUID }
      -# rubocop:disable Layout/LineLength
      - some_code
      -# rubocop:enable Layout/LineLength
    LIQUID

    it { should_not report_lint }
  end

  context 'when a control statement contains a Rails Template Dependency directive' do
    let(:liquid) { <<-LIQUID }
      -# Template Dependency: some/partial
      = render some_helper_method_that_returns_a_partial_name
    LIQUID

    it { should_not report_lint }
  end
end
