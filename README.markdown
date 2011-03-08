Ruby ISBNdb
===========
About
-----

Ruby ISBNdb is a simple, Ruby library that connects to [Amazon's ISBNdb Web Service](http://isbndb.com) and API. Ruby ISBNdb is written to mimic the ease of ActiveRecord and other ORM programs, without all the added hassles. It's still in beta phases, but it is almost fully functional for the basic search features of ISBNdb.

Why it's awesome
----------------

Ruby ISBNdb now uses [libxml-ruby](http://libxml.rubyforge.org/) - the fastest Ruby parser available for XML. Other parsers rely on REXML or hpricot, which are [show to be significantly slower](http://railstips.org/blog/archives/2008/08/11/parsing-xml-with-ruby/).

Installation
------------

Finally got it packaged as a gem!

    gem install ruby_isbndb

Alternatively, you can download the source from here and `require 'lib/isbndb'`

ActiveRecord-like Usage
-----------------------
Another reason why you'll love Ruby ISBNdb is it's similarity to ActiveRecord. In fact, it's *based* on ActiveRecord, so it should look similar. It's best to lead by example, so here are a few ways to search for books, authors, etc:

    @query = ISBNdb::Query.new("YOUR API KEY HERE")

    @query.find_book_by_isbn("978-0-9776-1663-3")
    @query.find_books_by_title("Agile Development")
    @query.find_author_by_name("Seth Vargo")
    @query.find_publisher_by_name("Pearson")

Advanced Usage
--------------
Additionally, you can also use a more advanced syntax for complete control:

    @query = ISBNdb::Query.new("YOUR API KEY HERE")

    @query.find(:collection => 'books', :where => { :isbn => '978-0-9776-1663-3' })
    @query.find(:collection => 'books', :where => { :author => 'Seth Vargo' }, :results => 'prices')
    
Options for `:collection` include **books**, **subjects**, **categories**, **authors**, and **publishers**.
		
If you are unfamiliar with some of these options, have a look at the [ISBNdb API](http://isbndb.com/docs/api/)

Processing Results
------------------
A `ResultSet` is nothing more than an enhanced array of `Result` objects. The easiest way to process results from ruby_isbndb is most easily done using the `.each` method.

    results = @query.find_books_by_title("Agile Development")
    results.each do |result|
      puts "title: #{result.title}"
      puts "isbn10: #{result.isbn}"
      puts "authors: #{result.authors_text}"
    end
    
**Note** calling a method on a `Result` object that is `empty?`, `blank?`, or `nil?` will *always* return `nil`. This was a calculated decision so that developers can do the following:

  puts "title: #{result.title}" unless result.title.nil?
  
versus

  puts "title: #{result.title}" unless result.title.nil? || result.title.blank? || result.title.empty?

because Amazon's ISBNdb.com API is generally inconsistent with respect to returning empty strings, whitespace characters, or nothing at all.

Pagination
----------
Ruby ISBNdb now include pagination! Pagination is based on the `ResultSet` object. The `ResultSet` object contains the methods `next_page` and `prev_page`... Their function should not require too much explanation. Here's a basic example:

    results = @query.find_books_by_title("ruby")
    results.next_page.each do |result|
      puts "title: #{result.title}"
    end
    
A more realistic example - getting **all** books of a certain title:

    results = @query.find_books_by_title("ruby")
    while results
      results.each do |result|
        puts "title: #{title}"
      end
      
      results = results.next_page
    end
    
It seems incredibly unlikely that a developer would ever use `prev_page`, but it's still there if you need it.

**Note**: `next_page` and `prev_page` return `nil` if the `ResultSet` is out of `Result` objects. If you try something like `results.next_page.next_page`, you could get a whiny nil. Think `LinkedLists` when working with `next_page` and `prev_page`.

**BIGGER NOTE**: `next_page` and `prev_page` BOTH make a subsequent call to the API, using up one of your 500 daily request limits. Please keep this in mind!

Know Bugs and Limitations
---------
- Result sets that return multiple sub-lists (like prices, pricehistory, and authors) are only populated with the *last* result
- The gem doesn't warn you if you are near/go over 500 requests per day (which is the limit unless you buy a plan)
- The system is severely lacking in tests, because I just never wrote them... Takers?
- Minimal support for multiple API-keys (manual management)