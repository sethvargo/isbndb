require 'spec_helper'

# These examples are used to test multiple books returned and a single book return
# Actual specs at the bottom of this file

shared_examples "AProperResultSet" do
  context 'initialize' do
    it 'should set all the instance variables' do
      @result_set.instance_variable_get('@uri').should == '/books.xml?access_key=ABC123&index1=title&results=details&value1=hello'
      @result_set.instance_variable_get('@collection').should == 'Book'
      @result_set.instance_variable_get('@current_page').should == 1
      @result_set.instance_variable_get('@parsed_response').should == @expected_parsed_response
    end
  end

  context 'size' do
    it 'should return the size of @results' do
      @result_set.size.should == @expected_result_size
    end
  end

  context 'each' do
    it 'should iterate over @results' do
      @result_set.each_with_index do |result,index|
        result.should == @result_set.instance_variable_get('@results')[index]
      end
    end
  end

  context '[]' do
    it 'should return the first result' do
      @result_set[0].should == @result_set.first
    end
  end

  context 'go_to_page' do
    it 'should get the total number of pages' do
      expect{ @result_set.go_to_page(1) }.to change { @result_set.instance_variable_get('@total_pages') }.to(167)
    end

    it 'should return if the page is invalid' do
      @result_set.go_to_page('foo').should be_nil
      @result_set.go_to_page(-1).should be_nil
      @result_set.go_to_page(138193289).should be_nil
    end

    it 'should return a new result set' do
      @result_set.go_to_page(2).should be_a(ISBNdb::ResultSet)
      @result_set.go_to_page(2).instance_variable_get('@uri').should include('page_number=2')
    end
  end

  context 'next_page' do
    it 'should go to the next page' do
      @result_set.next_page.should == @result_set.go_to_page(2)
    end

    it 'should return nil when there are no more pages' do
      @result_set.go_to_page(167).next_page.should be_nil
    end
  end

  context 'prev_page' do
    it 'should go to the previous page' do
      @result_set.go_to_page(2).prev_page.should == @result_set.go_to_page(1)
    end

    it 'should return nil when there is no previous page' do
      @result_set.go_to_page(1).prev_page.should be_nil
    end
  end

  context 'to_s' do
    it 'should return the correct string' do
      @result_set.to_s.should == '#<ResultSet::Book :total_results => ' + @expected_result_size.to_s + '>'
    end
  end

  context 'check_results' do
    it 'should raise an exception if there is an error message' do
      stub_request(:get, /http:\/\/isbndb\.com\/api\/books\.xml\?access_key=ABC123&index1=title(&page_number=(.+))?&results=details&value1=hello/).to_return(:body => File.new('spec/responses/access_key_error.xml'), :headers => {'Content-Type'=>'text/xml'})
      proc = lambda{ ISBNdb::ResultSet.new('/books.xml?access_key=ABC123&index1=title&results=details&value1=hello', :books) }

      proc.should raise_error(ISBNdb::AccessKeyError)
    end
  end

  context 'get_total_pages' do
    it 'should get the total number of pages' do
      @result_set.send(:get_total_pages).should == 167
    end
  end
end

describe "MultipleISBNdb::ResultSet" do
  before do
    stub_request(:get, /http:\/\/isbndb\.com\/api\/books\.xml\?access_key=ABC123&index1=title(&page_number=(.+))?&results=details&value1=hello/).to_return(:body => File.new('spec/responses/books_hello.xml'), :headers => {'Content-Type'=>'text/xml'})
    @result_set = ISBNdb::ResultSet.new('/books.xml?access_key=ABC123&index1=title&results=details&value1=hello', :books)
    @expected_result_size = 10
    @expected_parsed_response = {"server_time"=>"2012-06-16T20:10:13Z", "BookList"=>{"total_results"=>"1664", "page_size"=>"10", "page_number"=>"1", "shown_results"=>"10", "BookData"=>[{"book_id"=>"100th_day_of_school_a04", "isbn"=>"1590543947", "isbn13"=>"9781590543948", "Title"=>"100th Day of School", "TitleLong"=>"100th Day of School (Hello Reader Level 2)", "AuthorsText"=>"Angela Shelf Medearis, ", "PublisherText"=>{"publisher_id"=>"fitzgerald_books", "__content__"=>"Fitzgerald Books"}, "Details"=>{"change_time"=>"2011-03-08T18:28:45Z", "price_time"=>"2012-05-29T16:45:46Z", "edition_info"=>"Unknown Binding; 2007-01", "language"=>"", "physical_description_text"=>"6.0\"x9.0\"x0.5\"; 0.4 lb; 32 pages", "lcc_number"=>"", "dewey_decimal_normalized"=>"", "dewey_decimal"=>""}}, {"book_id"=>"100th_day_the", "isbn"=>"0439330173", "isbn13"=>"9780439330176", "Title"=>"100th Day, The", "TitleLong"=>"100th Day, The (level 1) (Hello Reader Level 1)", "AuthorsText"=>"Alayne Pick, Grace Maccarone, Laura Freeman (Illustrator)", "PublisherText"=>{"publisher_id"=>"cartwheel", "__content__"=>"Cartwheel"}, "Details"=>{"change_time"=>"2006-02-27T21:34:15Z", "price_time"=>"2012-05-29T16:46:08Z", "edition_info"=>"Paperback; 2002-12-01", "language"=>"", "physical_description_text"=>"32 pages", "lcc_number"=>"", "dewey_decimal_normalized"=>"", "dewey_decimal"=>""}}, {"book_id"=>"2011_hello_kitty_engagement_calendar", "isbn"=>"1423803558", "isbn13"=>"9781423803553", "Title"=>"2011 Hello Kitty Engagement Calendar", "TitleLong"=>nil, "AuthorsText"=>"Day Dream (Contributor)", "PublisherText"=>{"publisher_id"=>"day_dream", "__content__"=>"Day Dream"}, "Details"=>{"change_time"=>"2010-09-21T21:20:39Z", "price_time"=>"2012-03-24T04:44:44Z", "edition_info"=>"Calendar; 2010-08-01", "language"=>"", "physical_description_text"=>"7.0\"x8.5\"x0.9\"; 1.1 lb", "lcc_number"=>"", "dewey_decimal_normalized"=>"741", "dewey_decimal"=>"741"}}, {"book_id"=>"2011_hello_kitty_wall_calendar", "isbn"=>"1423803981", "isbn13"=>"9781423803980", "Title"=>"2011 Hello Kitty Wall Calendar", "TitleLong"=>nil, "AuthorsText"=>"Day Dream (Contributor)", "PublisherText"=>{"publisher_id"=>"day_dream", "__content__"=>"Day Dream"}, "Details"=>{"change_time"=>"2010-09-21T18:46:02Z", "price_time"=>"2012-04-25T20:26:40Z", "edition_info"=>"Calendar; 2010-08-01", "language"=>"", "physical_description_text"=>"10.8\"x11.8\"x0.2\"; 0.3 lb", "lcc_number"=>"", "dewey_decimal_normalized"=>"", "dewey_decimal"=>""}}, {"book_id"=>"2012_hello_kitty_2_year_pocket_planner_calendar", "isbn"=>"1423809424", "isbn13"=>"9781423809425", "Title"=>"2012 Hello Kitty 2 Year Pocket Planner Calendar", "TitleLong"=>nil, "AuthorsText"=>"Day Dream, ", "PublisherText"=>{"publisher_id"=>"day_dream", "__content__"=>"Day Dream"}, "Details"=>{"change_time"=>"2012-01-17T22:23:43Z", "price_time"=>"2012-03-04T05:32:03Z", "edition_info"=>"Calendar; 2011-07-01", "language"=>"", "physical_description_text"=>"3.5\"x6.2\"x0.0\"; 0.1 lb", "lcc_number"=>"", "dewey_decimal_normalized"=>"636", "dewey_decimal"=>"636"}}, {"book_id"=>"2012_hello_kitty_juvenile_activity_calendar", "isbn"=>"1423811194", "isbn13"=>"9781423811190", "Title"=>"2012 Hello Kitty Juvenile Activity Calendar", "TitleLong"=>nil, "AuthorsText"=>"Day Dream, ", "PublisherText"=>{"publisher_id"=>"day_dream", "__content__"=>"Day Dream"}, "Details"=>{"change_time"=>"2012-05-15T00:52:54Z", "price_time"=>"2012-06-16T20:10:13Z", "edition_info"=>"Calendar; 2011-07-01", "language"=>"", "physical_description_text"=>"11.0\"x12.0\"x0.3\"; 0.8 lb", "lcc_number"=>"", "dewey_decimal_normalized"=>"741", "dewey_decimal"=>"741"}}, {"book_id"=>"2012_hello_kitty_mini_calendar", "isbn"=>"1423809165", "isbn13"=>"9781423809166", "Title"=>"2012 Hello Kitty Mini Calendar", "TitleLong"=>nil, "AuthorsText"=>"Day Dream, ", "PublisherText"=>{"publisher_id"=>"day_dream", "__content__"=>"Day Dream"}, "Details"=>{"change_time"=>"2012-01-17T22:24:12Z", "price_time"=>"2012-02-09T06:11:01Z", "edition_info"=>"Calendar; 2011-07-01", "language"=>"", "physical_description_text"=>"6.2\"x6.9\"x0.2\"; 0.1 lb", "lcc_number"=>"", "dewey_decimal_normalized"=>"741", "dewey_decimal"=>"741"}}, {"book_id"=>"2012_hello_kitty_wall_calendar", "isbn"=>"1423809696", "isbn13"=>"9781423809692", "Title"=>"2012 Hello Kitty Wall Calendar", "TitleLong"=>nil, "AuthorsText"=>"Day Dream, ", "PublisherText"=>{"publisher_id"=>"day_dream", "__content__"=>"Day Dream"}, "Details"=>{"change_time"=>"2012-01-17T22:14:27Z", "price_time"=>"2012-02-09T06:02:14Z", "edition_info"=>"Calendar; 2011-07-01", "language"=>"", "physical_description_text"=>"10.6\"x11.8\"x0.2\"; 0.5 lb", "lcc_number"=>"", "dewey_decimal_normalized"=>"741", "dewey_decimal"=>"741"}}, {"book_id"=>"2012_hello_kitty_weekly_engagement_calendar", "isbn"=>"1423809092", "isbn13"=>"9781423809098", "Title"=>"2012 Hello Kitty Weekly Engagement Calendar", "TitleLong"=>nil, "AuthorsText"=>"Day Dream, ", "PublisherText"=>{"publisher_id"=>"day_dream", "__content__"=>"Day Dream"}, "Details"=>{"change_time"=>"2012-01-17T22:14:34Z", "price_time"=>"2012-02-08T12:37:05Z", "edition_info"=>"Calendar; 2011-07-01", "language"=>"", "physical_description_text"=>"7.2\"x8.5\"x0.9\"; 1.0 lb", "lcc_number"=>"", "dewey_decimal_normalized"=>"741", "dewey_decimal"=>"741"}}, {"book_id"=>"2_grrrls_hello_gorgeous", "isbn"=>"0439187370", "isbn13"=>"9780439187374", "Title"=>"Hello gorgeous", "TitleLong"=>"Hello gorgeous: a guide to style", "AuthorsText"=>"by Kristen Kemp", "PublisherText"=>{"publisher_id"=>"scholastic", "__content__"=>"New York : Scholastic, c2000."}, "Details"=>{"change_time"=>"2009-09-29T18:09:13Z", "price_time"=>"2011-03-25T22:20:05Z", "edition_info"=>"(pbk.) :$3.99", "language"=>"eng", "physical_description_text"=>"64 p. : ill. (some col.) ; 20 cm.", "lcc_number"=>"", "dewey_decimal_normalized"=>"", "dewey_decimal"=>""}}]}}
  end
  it_behaves_like "AProperResultSet" do
  end
end


describe "SingleISBNdb::ResultSet" do
  before do
    stub_request(:get, /http:\/\/isbndb\.com\/api\/books\.xml\?access_key=ABC123&index1=title(&page_number=(.+))?&results=details&value1=hello/).to_return(:body => File.new('spec/responses/single_book.xml'), :headers => {'Content-Type'=>'text/xml'})
    @result_set = ISBNdb::ResultSet.new('/books.xml?access_key=ABC123&index1=title&results=details&value1=hello', :books)
   @expected_parsed_response = {"server_time"=>"2012-06-16T20:10:13Z", "BookList"=>{"total_results"=>"1664", "page_size"=>"10", "page_number"=>"1", "shown_results"=>"1", "BookData"=>{"book_id"=>"100th_day_of_school_a04", "isbn"=>"1590543947", "isbn13"=>"9781590543948", "Title"=>"100th Day of School", "TitleLong"=>"100th Day of School (Hello Reader Level 2)", "AuthorsText"=>"Angela Shelf Medearis, ", "PublisherText"=>{"publisher_id"=>"fitzgerald_books", "__content__"=>"Fitzgerald Books"}, "Details"=>{"change_time"=>"2011-03-08T18:28:45Z", "price_time"=>"2012-05-29T16:45:46Z", "edition_info"=>"Unknown Binding; 2007-01", "language"=>"", "physical_description_text"=>"6.0\"x9.0\"x0.5\"; 0.4 lb; 32 pages", "lcc_number"=>"", "dewey_decimal_normalized"=>"", "dewey_decimal"=>""}}}}
    @expected_result_size = 1
  end
  it_behaves_like "AProperResultSet" do
  end
end

