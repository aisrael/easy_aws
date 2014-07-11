require 'spec_helper'

describe EasyAWS do

  it 'is a module' do
    EasyAWS.should be_a(Module)
  end
  describe String do
    subject { 'abc' }
    specify { subject.should eq('abc') }
    describe '#length' do
      it 'should be 3' do
        subject.length.should eq(3)
      end
    end
  end
end
