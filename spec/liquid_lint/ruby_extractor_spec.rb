# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::RubyExtractor do
  let(:extractor) { described_class.new }

  describe '#extract' do
    let(:sexp) { LiquidLint::RubyExtractEngine.new.call(normalize_indent(liquid)) }
    subject { extractor.extract(sexp) }

    context 'with an empty Liquid document' do
      let(:liquid) { '' }
      its(:source) { should == '' }
      its(:source_map) { should == {} }
    end

    context 'with verbatim text' do
      let(:liquid) { <<-LIQUID }
        | Hello world
      LIQUID

      its(:source) { should == '_liquid_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with verbatim text on multiple lines' do
      let(:liquid) { <<-LIQUID }
        |
          Hello
          world
      LIQUID

      its(:source) { should == '_liquid_lint_puts_0' }
      its(:source_map) { should == { 1 => 2 } }
    end

    context 'with verbatim text with trailing whitespace' do
      let(:liquid) { <<-LIQUID }
        ' Hello world
      LIQUID

      its(:source) { should == '_liquid_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with inline static HTML' do
      let(:liquid) { <<-LIQUID }
        <p><b>Hello world!</b></p>
      LIQUID

      its(:source) { should == '_liquid_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with control code' do
      let(:liquid) { <<-LIQUID }
        - some_expression
      LIQUID

      its(:source) { should == 'some_expression' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with output code' do
      let(:liquid) { <<-LIQUID }
        = some_expression
      LIQUID

      its(:source) { should == 'some_expression' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with output code with block contents' do
      let(:liquid) { <<-LIQUID }
        = simple_form_for User.new, url: some_url do |f|
          = f.input :email, autofocus: true
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        simple_form_for User.new, url: some_url do |f|
        f.input :email, autofocus: true
        end
      RUBY

      its(:source_map) { { 1 => 1, 2 => 2, 3 => 1 } }
    end

    context 'with output without escaping' do
      let(:liquid) { <<-LIQUID }
        == some_expression
      LIQUID

      its(:source) { should == 'some_expression' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with a code comment' do
      let(:liquid) { <<-LIQUID }
        / This line will not appear
      LIQUID

      its(:source) { should == '' }
      its(:source_map) { should == {} }
    end

    context 'with an HTML comment' do
      let(:liquid) { <<-LIQUID }
        /! This line will appear
      LIQUID

      its(:source) { should == '_liquid_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with an Internet Explorer conditional comment' do
      let(:liquid) { <<-LIQUID }
        /[if IE]
          Get a better browser
      LIQUID

      its(:source) { should == "_liquid_lint_puts_0\n_liquid_lint_puts_1" }
      its(:source_map) { should == { 1 => 2, 2 => 2 } }
    end

    context 'with doctype tag' do
      let(:liquid) { <<-LIQUID }
        doctype xml
      LIQUID

      its(:source) { should == '_liquid_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with an HTML tag' do
      let(:liquid) { <<-LIQUID }
        p A paragraph
      LIQUID

      its(:source) { should == "_liquid_lint_puts_0\n_liquid_lint_puts_1" }
      its(:source_map) { should == { 1 => 1, 2 => 1 } }
    end

    context 'with an HTML tag with interpolation' do
      let(:liquid) { <<-LIQUID }
        p A \#{adjective} paragraph for \#{noun}
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
      _liquid_lint_puts_0
      _liquid_lint_puts_1
      adjective
      _liquid_lint_puts_2
      noun
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1 } }
    end

    context 'with an HTML tag with static attributes' do
      let(:liquid) { <<-LIQUID }
        p class="highlight"
      LIQUID

      its(:source) { should == "_liquid_lint_puts_0\n_liquid_lint_puts_1" }
      its(:source_map) { should == { 1 => 1, 2 => 1 } }
    end

    context 'with an HTML tag with Ruby attributes' do
      let(:liquid) { <<-LIQUID }
        p class=user.class id=user.id
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        _liquid_lint_puts_0
        user.class
        user.id
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 1, 3 => 1 } }
    end

    context 'with a dynamic tag splat' do
      let(:liquid) { <<-LIQUID }
        *some_dynamic_tag Hello World!
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        _liquid_lint_puts_0
        some_dynamic_tag
        _liquid_lint_puts_1
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 1, 3 => 1 } }
    end

    context 'with an if statement' do
      let(:liquid) { <<-LIQUID }
        - if condition_true?
          | It's true!
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        _liquid_lint_puts_0
        end
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end

    context 'with an if/else statement' do
      let(:liquid) { <<-LIQUID }
        - if condition_true?
          | It's true!
        - else
          | It's false!
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        _liquid_lint_puts_0
        else
        _liquid_lint_puts_1
        end
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5 } }
    end

    context 'with an if/elsif/else statement' do
      let(:liquid) { <<-LIQUID }
        - if condition_true?
          | It's true!
        - elsif something_else?
          | ???
        - else
          | It's false!
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        _liquid_lint_puts_0
        elsif something_else?
        _liquid_lint_puts_1
        else
        _liquid_lint_puts_2
        end
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7 } }
    end

    context 'with an if/else statement with statements following it' do
      let(:liquid) { <<-LIQUID }
        - if condition_true?
          | It's true!
        - else
          | It's false!
        - following_statement
        - another_statement
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        _liquid_lint_puts_0
        else
        _liquid_lint_puts_1
        end
        following_statement
        another_statement
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 5, 7 => 6 } }
    end

    context 'with an output statement with statements following it' do
      let(:liquid) { <<-LIQUID }
        = some_output
        - some_statement
        - another_statement
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        some_output
        some_statement
        another_statement
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end

    context 'with an output statement that spans multiple lines' do
      let(:liquid) { <<-LIQUID }
        = some_output 1,
                      2,
                      3
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
      some_output 1,
      2,
      3
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end

    context 'with a control statement that spans multiple lines' do
      let(:liquid) { <<-LIQUID }
        - some_method 1,
                      2,
                      3
      LIQUID

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
      some_method 1,
      2,
      3
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end
  end
end
