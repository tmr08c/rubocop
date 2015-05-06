# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::LiteralInInterpolation do
  subject(:cop) { described_class.new }

  it 'accepts empty interpolation' do
    inspect_source(cop, '"this is #{a} silly"')
    expect(cop.offenses).to be_empty
  end

  shared_examples 'literal interpolation' do |literal|
    it "registers an offense for #{literal} in interpolation" do
      inspect_source(cop, %("this is the \#{#{literal}}"))
      expect(cop.offenses.size).to eq(1)
    end

    it "removes interpolation around #{literal}" do
      corrected = autocorrect_source(cop, %("this is the \#{#{literal}}"))
      expect(corrected).to eq("this is the #{literal}")
    end

    it "removes interpolation around #{literal} when there is more text" do
      corrected = autocorrect_source(cop, %("this is the \#{#{literal}} literally"))
      expect(corrected).to eq("this is the #{literal} literally")
    end

    it "removes interpolation around multiple #{literal}" do
      corrected = autocorrect_source(cop, %("this is the \#{#{literal}} with \#{#{literal}} now"))
      expect(corrected).to eq("this is the #{literal} with #{literal} now")
    end

    it "removes interpolation around #{literal} and leave real interpolation" do
      corrected = autocorrect_source(cop, %("this is the \#{#{literal}} with \#{a} now"))
      expect(corrected).to eq("this is the #{literal} with \#{a} now")
    end

    it "registers an offense only for final #{literal} in interpolation" do
      inspect_source(cop, %("this is the \#{#{literal};#{literal}}"))
      expect(cop.offenses.size).to eq(1)
    end
  end

  it_behaves_like('literal interpolation', 1)
  it_behaves_like('literal interpolation', -1)
  it_behaves_like('literal interpolation', 1_123)
  it_behaves_like('literal interpolation', 123_456_789_123_456_789)
  it_behaves_like('literal interpolation', 1.2e-3)
  it_behaves_like('literal interpolation', 0xaabb)
  it_behaves_like('literal interpolation', 0377)
  it_behaves_like('literal interpolation', 2.0)
  it_behaves_like('literal interpolation', [])
  it_behaves_like('literal interpolation', [1])
  it_behaves_like('literal interpolation', true)
  it_behaves_like('literal interpolation', false)
  it_behaves_like('literal interpolation', 'nil')

  shared_examples 'special keywords' do |keyword|
    it "accepts strings like #{keyword}" do
      inspect_source(cop, %("this is \#{#{keyword}} silly"))
      expect(cop.offenses).to be_empty
    end

    it "registers an offense for interpolation after #{keyword}" do
      inspect_source(cop, %("this is the \#{#{keyword}} \#{1}"))
      expect(cop.offenses.size).to eq(1)
    end
  end

  it_behaves_like('special keywords', '__FILE__')
  it_behaves_like('special keywords', '__LINE__')
  it_behaves_like('special keywords', '__END__')
  it_behaves_like('special keywords', '__ENCODING__')
end
