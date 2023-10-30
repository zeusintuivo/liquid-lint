# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::FileFinder do
  let(:config) { double }
  let(:excluded_patterns) { [] }

  subject { described_class.new(config) }

  describe '#find' do
    include_context 'isolated environment'

    subject { super().find(patterns, excluded_patterns) }

    context 'when no patterns are given' do
      let(:patterns) { [] }

      context 'and there are no Liquid files under the current directory' do
        it { should == [] }
      end

      context 'and there are Liquid files under the current directory' do
        before do
          `touch blah.liquid`
          `mkdir -p more`
          `touch more/more.liquid`
        end

        it { should == [] }
      end
    end

    context 'when files without a valid extension are given' do
      let(:patterns) { ['test.txt'] }

      context 'and those files exist' do
        before do
          `touch test.txt`
        end

        it { should == ['test.txt'] }

        context 'and that file is excluded directly' do
          let(:excluded_patterns) { ['test.txt'] }

          it { should == [] }
        end

        context 'and that file is excluded via glob pattern' do
          let(:excluded_patterns) { ['test.*'] }

          it { should == [] }
        end
      end

      context 'and those files do not exist' do
        it 'raises an error' do
          expect { subject }.to raise_error LiquidLint::Exceptions::InvalidFilePath
        end
      end
    end

    context 'when directories are given' do
      let(:patterns) { ['some-dir'] }

      context 'and those directories exist' do
        before do
          `mkdir -p some-dir`
        end

        context 'and they contain Liquid files' do
          before do
            `touch some-dir/test.liquid`
          end

          it { should == ['some-dir/test.liquid'] }

          context 'and those Liquid files are excluded explicitly' do
            let(:excluded_patterns) { ['some-dir/test.liquid'] }

            it { should == [] }
          end

          context 'and those Liquid files are excluded via glob' do
            let(:excluded_patterns) { ['some-dir/*'] }

            it { should == [] }
          end
        end

        context 'and they contain more directories with files with recognized extensions' do
          before do
            `mkdir -p some-dir/more-dir`
            `touch some-dir/more-dir/test.liquid`
          end

          it { should == ['some-dir/more-dir/test.liquid'] }
        end

        context 'and they contain files with some other extension' do
          before do
            `touch some-dir/test.txt`
          end

          it { should == [] }
        end
      end

      context 'and those directories do not exist' do
        it 'raises an error' do
          expect { subject }.to raise_error LiquidLint::Exceptions::InvalidFilePath
        end
      end

      context 'and the directory is the current directory' do
        let(:patterns) { ['.'] }

        context 'and the directory contains Liquid files' do
          before do
            `touch test.liquid`
          end

          it { should == ['test.liquid'] }

          context 'and those Liquid files are excluded explicitly' do
            let(:excluded_patterns) { ['test.liquid'] }

            it { should == [] }
          end

          context 'and those Liquid files are excluded explicitly with leading slash' do
            let(:excluded_patterns) { ['./test.liquid'] }

            it { should == [] }
          end

          context 'and those Liquid files are excluded via glob' do
            let(:excluded_patterns) { ['test.*'] }

            it { should == [] }
          end
        end

        context 'and directory contain files with some other extension' do
          before do
            `touch test.txt`
          end

          it { should == [] }
        end
      end
    end

    context 'when glob patterns are given' do
      let(:patterns) { ['test*.txt'] }

      context 'and no files match the glob pattern' do
        before do
          `touch some-file.txt`
        end

        it 'raises a descriptive error' do
          expect { subject }.to raise_error LiquidLint::Exceptions::InvalidFilePath
        end
      end

      context 'and a file named the same as the glob pattern exists' do
        before do
          `touch 'test*.txt' test1.txt`
        end

        it { should == ['test*.txt'] }
      end

      context 'and files matching the glob pattern exist' do
        before do
          `touch test1.txt test-some-words.txt`
        end

        it 'includes all matching files' do
          should == ['test-some-words.txt',
                     'test1.txt']
        end

        context 'and a glob pattern excludes a file' do
          let(:excluded_patterns) { ['*some*'] }

          it { should == ['test1.txt'] }
        end
      end
    end

    context 'when the same file is specified multiple times' do
      let(:patterns) { ['test.liquid'] * 3 }

      before do
        `touch test.liquid`
      end

      it { should == ['test.liquid'] }
    end

    context 'when an absolute file path is given' do
      let(:patterns) { [File.expand_path('test.liquid')] }

      before do
        `touch test.liquid`
      end

      context 'and a non-absolute exclusion matches the pattern' do
        let(:excluded_patterns) { ['test.liquid'] }

        it { should == [] }
      end
    end
  end
end
