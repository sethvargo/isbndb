require 'spec_helper'

describe NilClass do
  context 'blank?' do
    it 'should return true' do
      nil.blank?.should be_true
    end
  end
end
