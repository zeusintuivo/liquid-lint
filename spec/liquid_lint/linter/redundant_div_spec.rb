# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Linter::RedundantDiv do
  include_context 'linter'

  context 'when a div tag has no classes or IDs' do
    let(:liquid) { <<-LIQUID }
      div Hello world
    LIQUID

    it { should_not report_lint }
  end

  context 'when a div tag has a class attribute' do
    let(:liquid) { <<-LIQUID }
      div class="class" Hello World
    LIQUID

    it { should_not report_lint }
  end

  context 'when a div tag has an id attribute' do
    let(:liquid) { <<-LIQUID }
      div id="identifier" Hello World
    LIQUID

    it { should_not report_lint }
  end

  context 'when a div tag has a class attribute shortcut' do
    let(:liquid) { <<-LIQUID }
      div.class Hello world
    LIQUID

    it { should report_lint }
  end

  context 'when a div has an ID attribute shortcut' do
    let(:liquid) { <<-LIQUID }
      div#identifier Hello world
    LIQUID

    it { should report_lint }
  end

  context 'when a nameless tag has a class attribute shortcut' do
    let(:liquid) { <<-LIQUID }
      .class Hello
    LIQUID

    it { should_not report_lint }
  end

  context 'when a nameless tag has an ID attribute shortcut' do
    let(:liquid) { <<-LIQUID }
      #identifier Hello
    LIQUID

    it { should_not report_lint }
  end

  context 'when a div with a class attribute shortcut is deeply nested' do
    let(:liquid) { <<-LIQUID }
      tag
        child
          div.class
    LIQUID

    it { should report_lint line: 3 }
  end

  context 'when an offending div is contained within another offending div' do
    let(:liquid) { <<-LIQUID }
      div.class
        div.class2
    LIQUID

    it { should report_lint line: 1 }
    it { should report_lint line: 2 }
  end
end
