require 'spec_helper'

describe String do
  context 'is_plural?' do
    it 'should return true if the string is plural' do
      'authors'.is_plural?.should be_true
      'books'.is_plural?.should be_true
      'subjects'.is_plural?.should be_true
      'categories'.is_plural?.should be_true
      'publishers'.is_plural?.should be_true
    end

    it 'should return false if the string is not plural' do
      'author'.is_plural?.should_not be_true
      'book'.is_plural?.should_not be_true
      'subject'.is_plural?.should_not be_true
      'category'.is_plural?.should_not be_true
      'publisher'.is_plural?.should_not be_true
    end
  end

  context 'is_singular?' do
    it 'should return true if the string is singular' do
      'author'.is_singular?.should be_true
      'book'.is_singular?.should be_true
      'subject'.is_singular?.should be_true
      'category'.is_singular?.should be_true
      'publisher'.is_singular?.should be_true
    end

    it 'should return false if the string is not singular' do
      'authors'.is_singular?.should_not be_true
      'books'.is_singular?.should_not be_true
      'subjects'.is_singular?.should_not be_true
      'categories'.is_singular?.should_not be_true
      'publishers'.is_singular?.should_not be_true
    end
  end

  context 'titleize' do
    it 'should capitalize the first letter' do
      'author'.titleize.should == 'Author'
      'book'.titleize.should == 'Book'
      'subject'.titleize.should == 'Subject'
      'category'.titleize.should == 'Category'
      'publisher'.titleize.should == 'Publisher'
    end

    it 'should do nothing if the letter is already capitalized' do
      'Author'.titleize.should == 'Author'
      'Book'.titleize.should == 'Book'
      'Subject'.titleize.should == 'Subject'
      'Category'.titleize.should == 'Category'
      'Publisher'.titleize.should == 'Publisher'
    end
  end

  context 'singularize' do
    it 'should return the singular form of a word' do
      'authors'.singularize.should == 'author'
      'books'.singularize.should == 'book'
      'subjects'.singularize.should == 'subject'
      'categories'.singularize.should == 'category'
      'publishers'.singularize.should == 'publisher'
    end

    it 'should not alter an already singular word' do
      'author'.singularize.should == 'author'
      'book'.singularize.should == 'book'
      'subject'.singularize.should == 'subject'
      'category'.singularize.should == 'category'
      'publisher'.singularize.should == 'publisher'
    end
  end

  context 'pluralize' do
    it 'should return the plural form of a word' do
      'author'.pluralize.should == 'authors'
      'book'.pluralize.should == 'books'
      'subject'.pluralize.should == 'subjects'
      'category'.pluralize.should == 'categories'
      'publisher'.pluralize.should == 'publishers'
    end

    it 'should not alter an already singular word' do
      'authors'.pluralize.should == 'authors'
      'books'.pluralize.should == 'books'
      'subjects'.pluralize.should == 'subjects'
      'categories'.pluralize.should == 'categories'
      'publishers'.pluralize.should == 'publishers'
    end
  end

  context 'blank?' do
    it 'should return true for the empty string' do
      ''.blank?.should be_true
      '     '.blank?.should be_true
    end

    it 'should not return true for non-empty strings' do
      'hello'.blank?.should_not be_true
    end
  end

  context 'underscore' do
    it 'should convert the camel cased word to underscores' do
      'HelloWorld'.underscore.should == 'hello_world'
      'Cookie'.underscore.should == 'cookie'
      'AReallyLongStringThatMightConfuseTheMethod'.underscore.should == 'a_really_long_string_that_might_confuse_the_method'
    end

    it 'should not change already underscored words' do
      'hello_world'.underscore.should == 'hello_world'
      'cookie'.underscore.should == 'cookie'
      'a_really_long_string_that_might_confuse_the_method'.underscore.should == 'a_really_long_string_that_might_confuse_the_method'
    end
  end
end
