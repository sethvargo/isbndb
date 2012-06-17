require 'spec_helper'

describe ISBNdb::Result do
  context 'initialize' do
    it 'should set the @store instance variable' do
      ISBNdb::Result.new.instance_variable_get('@store').should_not be_nil
    end
  end

  context 'instance_methods' do
    context 'when the hash uses symbols for keys' do
      it 'should return an array of all methods' do
        ISBNdb::Result.new({ :foo => 'bar', :zip => 'zap' }).instance_methods.should == ['foo', 'zip']
      end
    end

    context 'when the hash is empty' do
      it 'should return an empty array' do
        ISBNdb::Result.new.instance_methods.should be_empty
      end
    end
  end

  context 'to_s' do
    context 'with no instance_methods' do
      it 'should return the correct string' do
        ISBNdb::Result.new.to_s.should == '#<Result @num_singleton_methods=0>'
      end
    end

    context 'with instance_methods' do
      it 'should return the correct string' do
        ISBNdb::Result.new({ :foo => 'bar', :zip => 'zap' }).to_s.should == '#<Result @num_singleton_methods=2>'
      end
    end
  end

  context 'inspect' do
    context 'with no instance_methods' do
      it 'should return the correct string' do
        ISBNdb::Result.new.inspect.should == '#<Result >'
      end
    end

    context 'with instance_methods' do
      it 'should return the correct string' do
        ISBNdb::Result.new({ :foo => 'bar', :zip => 'zap' }).inspect.should == '#<Result :foo => "bar", :zip => "zap">'
      end
    end
  end

  context 'build_result' do
    before do
      @result = ISBNdb::Result.new
    end

    context 'with cAmElCaSeD keys' do
      it 'should covert them to underscored keys' do
        @result.send(:build_result, { 'FooBar' => 'yep', 'ZipZap' => 'nope' }).should == { 'foo_bar' => 'yep', 'zip_zap' => 'nope' }
      end
    end

    context 'with under_scored keys' do
      it 'should not convert the keys' do
        @result.send(:build_result, { 'foo_bar' => 'yep', 'zip_zap' => 'nope' }).should == { 'foo_bar' => 'yep', 'zip_zap' => 'nope' }
      end
    end

    context 'with symbols for keys' do
      it 'should convert the keys to strings' do
        @result.send(:build_result, { :foo => 'bar', :zip => 'zap' }).should == { 'foo' => 'bar', 'zip' => 'zap' }
      end
    end

    context 'with strings for keys' do
      it 'not alter the keys' do
        @result.send(:build_result, { 'foo' => 'bar', 'zip' => 'zap' }).should == { 'foo' => 'bar', 'zip' => 'zap' }
      end
    end

    context 'with symbols as strings for keys' do
      it 'should convert the keys to strings' do
        @result.send(:build_result, { :'foo' => 'bar', :'zip' => 'zap' }).should == { 'foo' => 'bar', 'zip' => 'zap' }
      end
    end

    context 'with an empty hash' do
      it 'should return an empty hash' do
        @result.send(:build_result, {}).should be_empty
      end
    end

    context 'with a flat hash' do
      it 'should return the correct hash' do
        @result.send(:build_result, { :foo => 'bar', :zip => 'zap' }).should == { 'foo' => 'bar', 'zip' => 'zap' }
      end
    end

    context 'with a nested hash' do
      it 'should convert nested levels' do
        @result.send(:build_result, { 'foo' => { :bar => 'zip', 'LeftRight' => 'blue', :'MonkeyPatch' => 'true' } }).should == { 'foo' => { 'bar' => 'zip', 'left_right' => 'blue', 'monkey_patch' => 'true' } }
      end
    end
  end
end
