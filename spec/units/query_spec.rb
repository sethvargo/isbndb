require 'spec_helper'

describe ISBNdb::Query do
  before do
    stub_access_keys('ABC123')
  end

  context 'find' do
    context 'without params[:where]' do
      it 'should throw an exception' do
        lambda{ ISBNdb::Query.find }.should raise_error, 'No parameters specified! You must specify at least one parameter!'
      end
    end

    context 'with params[:where]' do
      context 'as a string' do
        it 'should throw an exception' do
          lambda{ ISBNdb::Query.find(:where => 'anything') }.should raise_error, 'params[:where] cannot be a String! It must be a Hash!'
        end
      end

      context 'as an array' do
        it 'should throw an exception' do
          lambda{ ISBNdb::Query.find(:where => ['anything', 'else']) }.should raise_error, 'params[:where] cannot be an Array! It must be a Hash!'
        end
      end

      context 'as a hash' do
        before do
          stub_request(:get, "http://isbndb.com/api/books.xml?access_key=ABC123&index1=title&results=details&value1=amazing").
            to_return(:body => File.new('spec/responses/search.xml'), :headers => {'Content-Type'=>'text/xml'})
         end

        it 'should not throw an exception' do
          lambda{ ISBNdb::Query.find(:where => {:title => 'amazing'} ) }.should_not raise_error
        end

        it 'should return an ISBNdb::ResultSet' do
          ISBNdb::Query.find(:where => {:title => 'amazing'}).should be_a(ISBNdb::ResultSet)
        end
      end

      context 'with an access key error' do
        before do
          stub_request(:get, "http://isbndb.com/api/books.xml?access_key=ABC123&index1=title&results=details&value1=amazing").to_return(:body => File.new('spec/responses/access_key_error.xml'), :headers => {'Content-Type'=>'text/xml'})
        end

        it 'should raise an exception' do
          lambda{ ISBNdb::Query.find(:where => {:title => 'amazing'}) }.should raise_error ISBNdb::AccessKeyError
        end

        after do
          ISBNdb::Query.access_key_set.prev_key!
        end
      end
    end
  end

  context 'keystats' do
    before do
      stub_request(:get, 'http://isbndb.com/api/books.xml?access_key=ABC123&results=keystats').to_return(:body => File.new('spec/responses/keystats.xml'), :headers => { 'Content-Type' => 'text/xml' })
    end

    it 'should return an Hash' do
      ISBNdb::Query.keystats.should be_a(Hash)
    end

    it('should return the number of granted requests'){ ISBNdb::Query.keystats['granted'].should == '2' }
    it('should return the access key'){ ISBNdb::Query.keystats['access_key'].should == 'ABC123' }
    it('should return the number of requests made'){ ISBNdb::Query.keystats['requests'].should == '5' }
    it('should return the account limit'){ ISBNdb::Query.keystats['limit'].should == '0' }
  end

  context 'to_s' do
    it 'the properly formatted string' do
      ISBNdb::Query.to_s.should =='#<ISBNdb::Query, @access_key=ABC123>'
    end
  end

  context 'method_missing' do
    context 'for a valid method it can handle' do
      method_calls = {
        rails4: {
          method_sgl: :find_book_by,
          method_plr: :find_books_by,
          arguments: { title: 'hello' }
        },
        rails3: {
          method_sgl: :find_book_by_title,
          method_plr: :find_books_by_title,
          arguments: 'hello'
        }
      }
      method_calls.each do | rails_style, method_call |
        it "should work for books with (#{rails_style} finder style)" do
          stub_request(:get, "http://isbndb.com/api/books.xml?access_key=ABC123&index1=title&results=details&value1=hello").to_return(:body => File.new('spec/responses/books_hello.xml'), :headers => {'Content-Type'=>'text/xml'})

          lambda{ ISBNdb::Query.send(method_call[:method_sgl], method_call[:arguments]) }.should_not raise_error
          lambda{ ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments]) }.should_not raise_error

          @books = ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments])
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
      end

      method_calls = {
        rails4: {
          method_sgl: :find_subject_by,
          method_plr: :find_subjects_by,
          arguments: { name: 'Ruby' }
        },
        rails3: {
          method_sgl: :find_subject_by_name,
          method_plr: :find_subjects_by_name,
          arguments: 'Ruby'
        }
      }
      method_calls.each do | rails_style, method_call |
        it "should work for subjects with (#{rails_style} finder style)" do
          stub_request(:get, "http://isbndb.com/api/subjects.xml?access_key=ABC123&index1=name&results=details&value1=Ruby").to_return(:body => File.new('spec/responses/subjects_ruby.xml'), :headers => {'Content-Type'=>'text/xml'})

          lambda{ ISBNdb::Query.send(method_call[:method_sgl], method_call[:arguments]) }.should_not raise_error
          lambda{ ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments]) }.should_not raise_error

          @subjects = ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments])
          @subjects.size.should == 10

          @subject = @subjects.first
          @subject.subject_id.should == 'ruby_napdowe_eksploatacja_podrcznik_akademicki'
          @subject.book_count.should == '1'
          @subject.marc_field.should == '650'
          @subject.marc_indicator_1.should be_nil
          @subject.marc_indicator_2.should == '9'
          @subject.name.should == 'ruby akademicki'
        end
      end

      method_calls = {
        rails4: {
          method_sgl: :find_category_by,
          method_plr: :find_categories_by,
          arguments: { name: 'fiction' }
        },
        rails3: {
          method_sgl: :find_category_by_name,
          method_plr: :find_categories_by_name,
          arguments: 'fiction'
        }
      }
      method_calls.each do | rails_style, method_call |
        it "should work for categories with (#{rails_style} finder style)" do
          stub_request(:get, "http://isbndb.com/api/categories.xml?access_key=ABC123&index1=name&results=details&value1=fiction").to_return(:body => File.new('spec/responses/categories_fiction.xml'), :headers => {'Content-Type'=>'text/xml'})

          lambda{ ISBNdb::Query.send(method_call[:method_sgl], method_call[:arguments]) }.should_not raise_error
          lambda{ ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments]) }.should_not raise_error

          @categories = ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments])
          @categories.size.should == 10

          @category = @categories.first
          @category.category_id.should == 'society.religion.christianity.denominations.catholicism.literature.fiction'
          @category.parent_id.should == 'society.religion.christianity.denominations.catholicism.literature'
          @category.name.should == 'Fiction'
          @category.details.should be_a(Hash)
        end
      end

      method_calls = {
        rails4: {
          method_sgl: :find_author_by,
          method_plr: :find_authors_by,
          arguments: { name: 'Seth' }
        },
        rails3: {
          method_sgl: :find_author_by_name,
          method_plr: :find_authors_by_name,
          arguments: 'Seth'
        }
      }
      method_calls.each do | rails_style, method_call |
        it "should work for authors with (#{rails_style} finder style)" do
          stub_request(:get, "http://isbndb.com/api/authors.xml?access_key=ABC123&index1=name&results=details&value1=Seth").to_return(:body => File.new('spec/responses/authors_seth.xml'), :headers => {'Content-Type'=>'text/xml'})

          lambda{ ISBNdb::Query.send(method_call[:method_sgl], method_call[:arguments]) }.should_not raise_error
          lambda{ ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments]) }.should_not raise_error

          @authors = ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments])
          @authors.size.should == 10

          @author = @authors.first
          @author.person_id.should == 'abraham_seth'
          @author.name.should == 'Abraham, Seth'
          @author.details.should be_a(Hash)
        end
      end

      method_calls = {
        rails4: {
          method_sgl: :find_publisher_by,
          method_plr: :find_publishers_by,
          arguments: { name: 'Francis' }
        },
        rails3: {
          method_sgl: :find_publisher_by_name,
          method_plr: :find_publishers_by_name,
          arguments: 'Francis'
        }
      }
      method_calls.each do | rails_style, method_call |
        it "should work for publishers with (#{rails_style} finder style)" do
          stub_request(:get, "http://isbndb.com/api/publishers.xml?access_key=ABC123&index1=name&results=details&value1=Francis").to_return(:body => File.new('spec/responses/publishers_francis.xml'), :headers => {'Content-Type'=>'text/xml'})

          lambda{ ISBNdb::Query.send(method_call[:method_sgl], method_call[:arguments]) }.should_not raise_error
          lambda{ ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments]) }.should_not raise_error

          @publishers = ISBNdb::Query.send(method_call[:method_plr], method_call[:arguments])
          @publishers.size.should == 10

          @publisher = @publishers.first
          @publisher.publisher_id.should == 'taylor_francis_a01'
          @publisher.name.should == ': Taylor & Francis'
          @publisher.details.should be_a(Hash)
        end
      end
    end

    context 'for an invalid method it can handle' do
      it 'should throw an exception' do
        lambda{ ISBNdb::Query.find_foo_by_bar('totes') }.should raise_error
      end
    end

    context 'for a method is can\'t handle' do
      it 'should throw an exception' do
        lambda{ ISBNdb::Query.foo_bar }.should raise_error
      end
    end
  end
end
