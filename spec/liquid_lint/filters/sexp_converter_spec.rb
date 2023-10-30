# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Filters::SexpConverter do
  describe '#call' do
    let(:array) { [:one, :two, [:three_one, :three_two]] }
    subject { described_class.new.call(array) }

    it 'returns a Sexp' do
      # The Sexp#initialize spec tests the actual conversion
      subject.should be_a LiquidLint::Sexp
    end
  end
end
