# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Linter::ControlStatementSpacing do
  include_context 'linter'

  context 'element missing space before =' do
    let(:liquid) { 'div= bad' }

    it { should report_lint }
  end

  context 'element missing space after =' do
    let(:liquid) { 'div =bad' }

    it { should report_lint }
  end

  context 'element missing space around =' do
    let(:liquid) { 'div=bad' }

    it { should report_lint }
  end

  context 'element too much space before =' do
    let(:liquid) { 'div  =bad' }

    it { should report_lint }
  end

  context 'element too much space after =' do
    let(:liquid) { 'div=  bad' }

    it { should report_lint }
  end

  context 'id missing space before =' do
    let(:liquid) { '#submit= bad' }

    it { should report_lint }
  end

  context 'id missing space after =' do
    let(:liquid) { '#submit =bad' }

    it { should report_lint }
  end

  context 'id missing space around =' do
    let(:liquid) { '#submit=bad' }

    it { should report_lint }
  end

  context 'id and class missing space around =' do
    let(:liquid) { '.some-class#submit=bad' }

    it { should report_lint }
  end

  context 'id too much space before =' do
    let(:liquid) { '#submit  =bad' }

    it { should report_lint }
  end

  context 'id too much space after =' do
    let(:liquid) { '#submit=  bad' }

    it { should report_lint }
  end

  context 'class missing space before =' do
    let(:liquid) { '.klass= bad' }

    it { should report_lint }
  end

  context 'class missing space after =' do
    let(:liquid) { '.klass =bad' }

    it { should report_lint }
  end

  context 'class missing space around =' do
    let(:liquid) { '.klass=bad' }

    it { should report_lint }
  end

  context 'class too much space before =' do
    let(:liquid) { '.klass  =bad' }

    it { should report_lint }
  end

  context 'class too much space after =' do
    let(:liquid) { '.klass=  bad' }

    it { should report_lint }
  end

  context 'class with hyphen missing space before =' do
    let(:liquid) { '.some-klass= bad' }

    it { should report_lint }
  end

  context 'class with hyphen missing space after =' do
    let(:liquid) { '.some-klass =bad' }

    it { should report_lint }
  end

  context 'class with hyphen missing space around =' do
    let(:liquid) { '.some-klass=bad' }

    it { should report_lint }
  end

  context 'class with hyphen too much space before =' do
    let(:liquid) { '.some-klass  =bad' }

    it { should report_lint }
  end

  context 'class with hyphen too much space after =' do
    let(:liquid) { '.some-klass=  bad' }

    it { should report_lint }
  end

  context 'ruby code that contains a properly formatted equal sign' do
    let(:liquid) { 'div =bad = 1' }

    it { should report_lint }
  end

  context 'ruby code that contains a properly formatted equal sign' do
    let(:liquid) { 'div= bad = 1' }

    it { should report_lint }
  end

  context 'ruby code that contains a properly formatted equal sign' do
    let(:liquid) { 'div  = bad = 1' }

    it { should report_lint }
  end

  # OK

  context 'ruby code that contains an equal sign without spacing' do
    let(:liquid) { 'div = ok=1' }

    it { should_not report_lint }
  end

  context 'element with hyphen' do
    let(:liquid) { 'div - ok' }

    it { should_not report_lint }
  end

  context 'control statement without element' do
    let(:liquid) { '= ok' }

    it { should_not report_lint }
  end

  context 'attribute with equal sign without spacing' do
    let(:liquid) { 'a href=ok' }

    it { should_not report_lint }
  end

  context 'when leading whitespace (=<) is used' do
    context 'and it has appropriate spacing' do
      let(:liquid) { 'title =< "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:liquid) { 'title=< "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:liquid) { 'title =<"Something"' }

      it { should report_lint }
    end
  end

  context 'when trailing whitespace (=>) is used' do
    context 'and it has appropriate spacing' do
      let(:liquid) { 'title => "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:liquid) { 'title=> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:liquid) { 'title =>"Something"' }

      it { should report_lint }
    end
  end

  context 'when whitespace (=<>) is used' do
    context 'and it has appropriate spacing' do
      let(:liquid) { 'title =<> "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:liquid) { 'title=<> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:liquid) { 'title =<>"Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling (==) is used' do
    context 'and it has appropriate spacing' do
      let(:liquid) { 'title == "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:liquid) { 'title== "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:liquid) { 'title =="Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling with leading whitespace (==<) is used' do
    context 'and it has appropriate spacing' do
      let(:liquid) { 'title ==< "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:liquid) { 'title==< "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:liquid) { 'title ==<"Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling with trailing whitespace (==>) is used' do
    context 'and it has appropriate spacing' do
      let(:liquid) { 'title ==> "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:liquid) { 'title==> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:liquid) { 'title ==>"Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling with whitespace (==<>) is used' do
    context 'and it has appropriate spacing' do
      let(:liquid) { 'title ==<> "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:liquid) { 'title==<> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:liquid) { 'title ==<>"Something"' }

      it { should report_lint }
    end
  end
end
