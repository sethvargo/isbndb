require 'spec_helper'

describe ISBNdb::Query do
  before do
    @query = ISBNdb::Query.new('ABC123')

    stub_request(:get, 'http://isbndb.com/api/books.xml?access_key=ABC123&results=keystats').
      to_return(:body => File.new('spec/responses/keystats.xml'), :headers => { 'Content-Type' => 'text/xml' })
  end

  context 'initialize' do
    context 'the @access_key_set instance variables' do
      it 'should be set' do
        @query.instance_variable_get('@access_key_set').should_not be_nil
      end

      context 'with no access keys provided' do
        before { @query = ISBNdb::Query.new }

        it 'should have no elements' do
          @query.instance_variable_get('@access_key_set').size.should == 0
        end
      end

      context 'with a single key provided' do
        before { @query = ISBNdb::Query.new('ABC123') }

        it 'should have one element' do
          @query.instance_variable_get('@access_key_set').size.should == 1
        end
      end

      context 'with multiple keys provided' do
        before { @query = ISBNdb::Query.new('ABC123', 'DEF456', 'GHI789') }

        it 'should have 3 elements' do
          @query.instance_variable_get('@access_key_set').size.should == 3
        end
      end
    end
  end

  context 'find' do
    context 'without params[:where]' do
      it 'should throw an exception' do
        lambda{ @query.find }.should raise_error, 'No parameters specified! You must specify at least one parameter!'
      end
    end

    context 'with params[:where]' do
      context 'as a string' do
        it 'should throw an exception' do
          lambda{ @query.find(:where => 'anything') }.should raise_error, 'params[:where] cannot be a String! It must be a Hash!'
        end
      end

      context 'as an array' do
        it 'should throw an exception' do
          lambda{ @query.find(:where => ['anything', 'else']) }.should raise_error, 'params[:where] cannot be an Array! It must be a Hash!'
        end
      end

      context 'as a hash' do
        before do
          stub_request(:get, "http://isbndb.com/api/books.xml?access_key=ABC123&index1=title&results=details&value1=amazing").
            to_return(:body => File.new('spec/responses/search.xml'), :headers => {'Content-Type'=>'text/xml'})
         end

        it 'should not throw an exception' do
          lambda{ @query.find(:where => {:title => 'amazing'} ) }.should_not raise_error
        end

        it 'should return an ISBNdb::ResultSet' do
          @query.find(:where => {:title => 'amazing'}).should be_a(ISBNdb::ResultSet)
        end
      end

      context 'with an access key error' do
        before do
          stub_request(:get, "http://isbndb.com/api/books.xml?access_key=ABC123&index1=title&results=details&value1=amazing").
            to_return(:body => File.new('spec/responses/access_key_error.xml'), :headers => {'Content-Type'=>'text/xml'})
        end

        it 'should raise an exception' do
          lambda{ @query.find(:where => {:title => 'amazing'} ) }.should raise_error ISBNdb::AccessKeyError
        end
      end
    end
  end

  context 'keystats' do
    it 'should return an Hash' do
      @query.keystats.should be_a(Hash)
    end

    it('should return the number of granted requests'){ @query.keystats['granted'].should == '2' }
    it('should return the access key'){ @query.keystats['access_key'].should == 'ABC123' }
    it('should return the number of requests made'){ @query.keystats['requests'].should == '5' }
    it('should return the account limit'){ @query.keystats['limit'].should == '0' }
  end

  context 'to_s' do
    it 'the properly formatted string' do
      @query.to_s.should =='#<ISBNdb::Query, @access_key=ABC123>'
    end
  end

  context 'method_missing' do
    context 'for a method it can handle' do
      before do


      end

      it 'should work for books' do
        stub_request(:get, "http://isbndb.com/api/books.xml?access_key=ABC123&index1=title&results=details&value1=hello").to_return(:body => File.new('spec/responses/books_hello.xml'), :headers => {'Content-Type'=>'text/xml'})

        lambda{ @query.find_book_by_title('hello') }.should_not raise_error
        lambda{ @query.find_books_by_title('hello') }.should_not raise_error

        @books = @query.find_books_by_title('hello')
        @books.size.should == 10

        @book = @books.first
        @book.book_id.should == '100th_day_of_school_a04'
        @book.isbn.should == '1590543947'
        @book.isbn13.should == '9781590543948'
        @book.title.should == '100th Day of School'
        @book.title_long.should == '100th Day of School (Hello Reader Level 2)'
        @book.authors_text.should == 'Angela Shelf Medearis, '
        @book.publisher_text.should be_a(Hash)
        @book.details.should be_a(Hash)
      end

      it 'should work for subjects' do
        stub_request(:get, "http://isbndb.com/api/subjects.xml?access_key=ABC123&index1=name&results=details&value1=Ruby").to_return(:body => File.new('spec/responses/subjects_ruby.xml'), :headers => {'Content-Type'=>'text/xml'})

        lambda{ @query.find_subject_by_name('Ruby') }.should_not raise_error
        lambda{ @query.find_subjects_by_name('Ruby') }.should_not raise_error

        @subjects = @query.find_subjects_by_name('Ruby')
        @subjects.size.should == 10

        @subject = @subjects.first
        @subject.subject_id.should == 'ruby_napdowe_eksploatacja_podrcznik_akademicki'
        @subject.book_count.should == '1'
        @subject.marc_field.should == '650'
        @subject.marc_indicator_1.should be_nil
        @subject.marc_indicator_2.should == '9'
        @subject.name.should == 'ruby akademicki'
      end

      it 'should work for categories' do
        stub_request(:get, "http://isbndb.com/api/categories.xml?access_key=ABC123&index1=name&results=details&value1=fiction").to_return(:body => File.new('spec/responses/categories_fiction.xml'), :headers => {'Content-Type'=>'text/xml'})

        lambda{ @query.find_category_by_name('fiction') }.should_not raise_error
        lambda{ @query.find_categories_by_name('fiction') }.should_not raise_error

        @categories = @query.find_categories_by_name('fiction')
        @categories.size.should == 10

        @category = @categories.first
        @category.category_id.should == 'society.religion.christianity.denominations.catholicism.literature.fiction'
        @category.parent_id.should == 'society.religion.christianity.denominations.catholicism.literature'
        @category.name.should == 'Fiction'
        @category.details.should be_a(Hash)
      end

      it 'should work for authors' do
        stub_request(:get, "http://isbndb.com/api/authors.xml?access_key=ABC123&index1=name&results=details&value1=Seth").to_return(:body => File.new('spec/responses/authors_seth.xml'), :headers => {'Content-Type'=>'text/xml'})

        lambda{ @query.find_author_by_name('Seth') }.should_not raise_error
        lambda{ @query.find_authors_by_name('Seth') }.should_not raise_error

        @authors = @query.find_authors_by_name('Seth')
        @authors.size.should == 10

        @author = @authors.first
        @author.person_id.should == 'abraham_seth'
        @author.name.should == 'Abraham, Seth'
        @author.details.should be_a(Hash)
      end

      it 'should work for publishers' do
        stub_request(:get, "http://isbndb.com/api/publishers.xml?access_key=ABC123&index1=name&results=details&value1=Francis").to_return(:body => File.new('spec/responses/publishers_francis.xml'), :headers => {'Content-Type'=>'text/xml'})

        lambda{ @query.find_publisher_by_name('Francis') }.should_not raise_error
        lambda{ @query.find_publishers_by_name('Francis') }.should_not raise_error

        @publishers = @query.find_publishers_by_name('Francis')
        @publishers.size.should == 10

        @publisher = @publishers.first
        @publisher.publisher_id.should == 'taylor_francis_a01'
        @publisher.name.should == ': Taylor & Francis'
        @publisher.details.should be_a(Hash)
      end
    end
  end
end
