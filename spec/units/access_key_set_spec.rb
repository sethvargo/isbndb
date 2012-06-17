require 'spec_helper'

describe ISBNdb::AccessKeySet do
  before do
    stub_access_keys('ABC123', 'DEF456', 'GHI789')
    @access_key_set = ISBNdb::AccessKeySet.new
  end

  context 'size' do
    it 'should return 0 if there are no keys' do
      stub_access_keys
      ISBNdb::AccessKeySet.new.size.should == 0
    end

    it 'should return the number of access keys' do
      @access_key_set.size.should == 3
    end
  end

  context 'current_index' do
    it 'should return the current index' do
      @access_key_set.current_index.should == 0
    end
  end

  context 'current_key' do
    it 'should return the current key' do
      @access_key_set.current_key.should == 'ABC123'
    end
  end

  context 'next_key!' do
    it 'should advance to the next key' do
      expect{ @access_key_set.next_key! }.to change{ @access_key_set.current_key }.from('ABC123').to('DEF456')
    end

    it 'should return the new key' do
      @access_key_set.next_key!.should == 'DEF456'
    end
  end

  context 'next_key' do
    it 'should return the next key' do
      @access_key_set.next_key.should == 'DEF456'
    end
  end

  context 'prev_key!' do
    before do
      @access_key_set.instance_variable_set('@current_index', 1)
    end

    it 'should de-advance to the prev key' do
      expect{ @access_key_set.prev_key! }.to change{ @access_key_set.current_key }.from('DEF456').to('ABC123')
    end

    it 'should return the new key' do
      @access_key_set.prev_key!.should == 'ABC123'
    end
  end

  context 'prev_key' do
    before do
      @access_key_set.instance_variable_set('@current_index', 1)
    end

    it 'should return the prev key' do
      @access_key_set.prev_key.should == 'ABC123'
    end
  end

  context 'use_key' do
    it 'should use an existing key' do
      @access_key_set.use_key('GHI789').should == 'GHI789'
    end

    it 'should create a new key if it does not already exist' do
      @access_key_set.use_key('NEW_KEY').should == 'NEW_KEY'
      @access_key_set.instance_variable_get('@access_keys').should include('NEW_KEY')
    end
  end

  context 'remove_key' do
    it 'should do nothing if the key does not exist' do
      expect{ @access_key_set.remove_key('NOPE') }.not_to change{ @access_key_set.instance_variable_get('@access_keys') }
    end

    it 'should remove the key if it exists' do
      expect{ @access_key_set.remove_key('ABC123') }.to change{ @access_key_set.instance_variable_get('@access_keys') }.from(['ABC123', 'DEF456', 'GHI789']).to(['DEF456', 'GHI789'])
    end
  end

  context 'to_s' do
    it 'should return the correct string' do
      @access_key_set.to_s.should == '#<AccessKeySet @keys=["ABC123", "DEF456", "GHI789"]>'
    end
  end
end
