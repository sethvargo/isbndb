Ruby ISBNdb
===========
About
-----
Ruby ISBNdb is a simple, Ruby library that connects to [ISBNdb.com's Web Service](http://isbndb.com) and API. Ruby ISBNdb is written to mimic the ease of ActiveRecord and other ORM programs, without all the added hassles. It's still in beta phases, but it is almost fully functional for the basic search features of ISBNdb.

Why it's awesome
----------------
Ruby ISBNdb now uses [libxml-ruby](http://libxml.rubyforge.org/) - the fastest Ruby parser available for XML. Other parsers rely on REXML or hpricot, which are [show to be significantly slower](http://railstips.org/blog/archives/2008/08/11/parsing-xml-with-ruby/). libxml has been shown to have the fastest HTTP request AND fastest XML-parser to date!

Instead of dealing with complicated hashes and arrays, Ruby ISBNdb populates a `ResultSet` filled with `Result` objects that behave as one would expect. Simply call `@book.title` or `@author.name`! Once a `Result` object is built, it's persistent too! That means that the XML-DOM returned by ISBNdb is parsed exactly once for each request, instead of every method call like similar versions of this gem.

Version 1.5.0 now supports API-key management! The new APIKeySet supports auto-rollover - whenever one key is used up, it will automatically try the next key in the set. Once it runs out of keys, it will raise an ISBNdb::AccessKeyError. See the docs below for sample usage!

Ruby ISBNdb is under active development! More features will be coming soon!

Installation
------------
Finally got it packaged as a gem!

    gem install isbndb

Alternatively, you can download the source from here and `require 'lib/isbndb'`

**Special Thanks** to:

&nbsp;&nbsp;[Terje Tjervaag](https://github.com/terje)<br />
&nbsp;&nbsp;[http://thedailyt.com](http://thedailyt.com)

for giving up the `isbndb` gem! Thank you!

Basic Setup
-----------
Simply create a query instance variable and you're on your way:

    # will auto-rollover to API-KEY-2 when API-KEY-1 meets max requests
    @query = ISBNdb::Query.new(["API-KEY-1", "API-KEY-2", "API-KEY-3"])

ActiveRecord-like Usage
-----------------------
Another reason why you'll love Ruby ISBNdb is it's similarity to ActiveRecord. In fact, it's *based* on ActiveRecord, so it should look similar. It's best to lead by example, so here are a few ways to search for books, authors, etc:

    @query.find_book_by_isbn("978-0-9776-1663-3")
    @query.find_books_by_title("Agile Development")
    @query.find_author_by_name("Seth Vargo")
    @query.find_publisher_by_name("Pearson")

Advanced Usage
--------------
Additionally, you can also use a more advanced syntax for complete control:

    @query.find(:collection => 'books', :where => { :isbn => '978-0-9776-1663-3' })
    @query.find(:collection => 'books', :where => { :author => 'Seth Vargo' }, :results => 'prices')
    
Options for `:collection` include **books**, **subjects**, **categories**, **authors**, and **publishers**.
		
If you are unfamiliar with some of these options, have a look at the [ISBNdb API](http://isbndb.com/docs/api/)

Processing Results
------------------
A `ResultSet` is nothing more than an enhanced array of `Result` objects. The easiest way to process results from Ruby ISBNdb is most easily done using the `.each` method.

    results = @query.find_books_by_title("Agile Development")
    results.each do |result|
      puts "title: #{result.title}"
      puts "isbn10: #{result.isbn}"
      puts "authors: #{result.authors_text}"
    end
    
**Note**: calling a method on a `Result` object that is `empty?`, `blank?`, or `nil?` will *always* return `nil`. This was a calculated decision so that developers can do the following:

    puts "title: #{result.title}" unless result.title.nil?
  
versus

    puts "title: #{result.title}" unless result.title.nil? || result.title.blank? || result.title.empty?

because ISBNdb.com API is generally inconsistent with respect to returning empty strings, whitespace characters, or nothing at all.

**Note**: XML-keys to method names are inversely mapped. CamelCased XML keys and attributes (like BookData or TitleLong) are converted to lowercase under_scored methods (like book_data or title_long). ALL XML keys and attributes are mapped in this way.

Pagination
----------
Ruby ISBNdb now include pagination! Pagination is based on the `ResultSet` object. The `ResultSet` object contains the methods `go_to_page`, `next_page`, and `prev_page`... Their function should not require too much explanation. Here's a basic example:

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

Because there may be cases where a developer may need a specific page, the `go_to_page` method also exists. Consider an example where you batch-process books into your own database (which is probably against Copyright laws, but you don't seem to care...):

    results = @query.find_books_by_title("ruby")
    results = results.go_to_page(50) # where 50 is the page number you want

**Note**: `go_to_page`, `next_page` and `prev_page` return `nil` if the `ResultSet` is out of `Result` objects. If you try something like `results.next_page.next_page`, you could get a whiny nil. Think `LinkedLists` when working with `go_to_page`, `next_page` and `prev_page`.

**BIGGER NOTE**: `go_to_page`, `next_page` and `prev_page` BOTH make a subsequent call to the API, using up one of your 500 daily request limits. Please keep this in mind!

Advanced Key Management
-----------------------
With version 1.5.0, a new AccessKeySet allows for easy key management! It's controlled through the main @query.

    @access_key_set = @query.access_key_set

    @access_key_set.current_key                 # gets the current key
    @access_key_set.next_key                    # gets the next key
    @access_key_set.next_key!                   # advance the pointer (equivalent to @access_key_set.current_key = @access_key_set.next_key)
    @access_key_set.prev_key                    # gets the previous key
    @access_key_set.prev_key!                   # advance the pointer (equivalent to @access_key_set.current_key = @access_key_set.prev_key)
    @access_key_set.use_key('abc123foobar')     # use and existing key (or add it if doesn't exist)

All methods will return `nil` (except `use_key`) whenever the key does not exist.

Statistics
----------
Ruby ISBNdb now supports basic statistics (from the server):

    @query.keystats # => {:requests => 50, :granted => 49}
    @query.keystats[:granted] # => 49
    
**Note**: Ironically, this information also comes from the server, so it counts as a request...

Exceptions
----------
Ruby ISBNdb could raise the following possible exceptions:

    ISBNdb::AccessKeyError
    ISBNdb::InvalidURIError
    
You will most likely encounter `ISBNdb::AccessKeyError` when you have reached your 500-request daily limit. `ISBNdb::InvalidURIError` usually occurs when using magic finder methods with typographical errors.

A Real-Life Example
-------------------
Here is a real-life example of how to use Ruby ISBNdb. Imagine a Rails application that recommends books. You have written a model, `Book`, that has a variety of methods. One of those class methods, `similar`, returns a list of book isbn values that are similar to the current book. Here's how one may do that:

    # books_controller.rb
    def simliar
      @book = Book.find(params[:id])
      @query = ISBNdb::Query.new(['API-KEY-1', 'API-KEY-2'])
      @isbns = @book.similar # returns an array like [1234567890, 0987654321, 3729402827...]
      
      @isbns.each do |isbn|
        begin
          (@books ||= []) << @query.find_book_by_isbn(isbn).first
        rescue ISBNdb::AccessKeyError
          SomeMailer.send_limit_email.deliver!
        end
      end
    end

    # similar.html.erb
    <h1>The following books are recommeded for you:</h1>
    <% @books.each do |book| %>
      <div class="book">
        <h2><%= book.title_long %></h2>
        <p><strong>authors</strong>: <%= book.authors_text %></p>
      </div>
    <% end %>
    
Testing
-------
[![Build Status](http://travis-ci.org/sethvargo/isbndb.png)](http://travis-ci.org/sethvargo/isbndb)

Know Bugs and Limitations
-------------------------
- Result sets that return multiple sub-lists (like prices, pricehistory, and authors) are only populated with the *last* result

Change Log
----------
2011-3-11 - Officially changed from ruby_isbndb to isbndb with special thanks to [Terje Tjervaag](https://github.com/terje) for giving up the gem name :)