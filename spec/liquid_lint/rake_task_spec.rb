# frozen_string_literal: true

require 'spec_helper'
require 'liquid_lint/rake_task'
require 'tempfile'

describe LiquidLint::RakeTask do
  before(:all) do
    LiquidLint::RakeTask.new do |t|
      t.quiet = true
    end
  end

  let(:file) do
    Tempfile.new(%w[liquid-file .liquid]).tap do |f|
      f.write(liquid)
      f.close
    end
  end

  def run_task
    Rake::Task[:liquid_lint].tap do |t|
      t.reenable # Allows us to execute task multiple times
      t.invoke(file.path)
    end
  end

  context 'when Liquid document is valid' do
    let(:liquid) { "p Hello world\n" }

    it 'executes without error' do
      expect { run_task }.not_to raise_error
    end
  end

  context 'when Liquid document is invalid' do
    let(:liquid) { '%tag' }

    it 'raises an error' do
      expect { run_task }.to raise_error RuntimeError
    end
  end
end
