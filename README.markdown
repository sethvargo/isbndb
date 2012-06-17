Ruby ISBNdb
===========
Ruby ISBNdb is a simple, Ruby library that connects to [ISBNdb.com's Web Service](http://isbndb.com) and API. Ruby ISBNdb is written to mimic the ease of ActiveRecord and other ORM programs, without all the added hassles. It's still in beta phases, but it is almost fully functional for the basic search features of ISBNdb.

Version 1.x
-----------
*ISBNdb 1.x.x has been deprecated!*. You should upgrade to the new version as soon as possible. The old documentation is still available in the [git history](https://github.com/sethvargo/isbndb/tree/75cfe76d096f92b2dfaf1c1b42d7c84ff86fcbc0). There are *significant* changes in this new version, so please test appropriately.

Installation
------------
To get started, install the gem:

    gem install isbndb

Alternatively, you can add it to your Gemfile:

```ruby
gem 'isbndb', '~> 2.0.0'
```

Basic Setup
-----------
To get started, you'll need to create a `config/isbndb.yml` file in your project root. It should look like this:

```yml
access_keys:
  - KEY_1
  - KEY_2
  ...
```

Where you list your access keys. This was in response to security holes in version 1.x where values were passed directly to the initializer.

Now you're ready to get started:

```ruby
@query = ISBNdb::Query.find_book_by_name('Ruby')
```

ActiveRecord-like Usage
-----------------------
Another reason why you'll love Ruby ISBNdb is it's similarity to ActiveRecord. In fact, it's *based* on ActiveRecord, so it should look similar. It's best to lead by example, so here are a few ways to search for books, authors, etc:

```ruby
ISBNdb::Query.find_book_by_isbn("978-0-9776-1663-3")
ISBNdb::Query.find_books_by_title("Agile Development")
ISBNdb::Query.find_author_by_name("Seth Vargo")
ISBNdb::Query.find_publisher_by_name("Pearson")
```

Advanced Usage
--------------
Additionally, you can also use a more advanced syntax for complete control:

```ruby
ISBNdb::Query.find(:collection => 'books', :where => { :isbn => '978-0-9776-1663-3' })
ISBNdb::Query.find(:collection => 'books', :where => { :author => 'Seth Vargo' }, :results => 'prices')
```

Options for `:collection` include **books**, **subjects**, **categories**, **authors**, and **publishers**.

If you are unfamiliar with some of these options, have a look at the [ISBNdb API](http://isbndb.com/docs/api/)

Processing Results
------------------
A `ResultSet` is nothing more than an enhanced array of `Result` objects. The easiest way to process results from Ruby ISBNdb is most easily done using the `.each` method.

```ruby
results = ISBNdb::Query.find_books_by_title("Agile Development")
results.each do |result|
  puts "title: #{result.title}"
  puts "isbn10: #{result.isbn}"
  puts "authors: #{result.authors_text}"
end
```

**Note**: calling a method on a `Result` object that is `empty?`, `blank?`, or `nil?` will *always* return `nil`. This was a calculated decision so that developers can do the following:

```ruby
puts "title: #{result.title}" unless result.title.nil?
```

versus

```ruby
puts "title: #{result.title}" unless result.title.nil? || result.title.blank? || result.title.empty?
```

because ISBNdb.com API is generally inconsistent with respect to returning empty strings, whitespace characters, or nothing at all.

**Note**: XML-keys to method names are inversely mapped. CamelCased XML keys and attributes (like BookData or TitleLong) are converted to lowercase under_scored methods (like book_data or title_long). ALL XML keys and attributes are mapped in this way.

Pagination
----------
Pagination is based on the `ResultSet` object. The `ResultSet` object contains the methods `go_to_page`, `next_page`, and `prev_page`... Their function should not require too much explanation. Here's a basic example:

```ruby
results = ISBNdb::Query.find_books_by_title("ruby")
results.next_page.each do |result|
  puts "title: #{result.title}"
end
```

A more realistic example - getting **all** books of a certain title:

```ruby
results = ISBNdb::Query.find_books_by_title("ruby")
while results
  results.each do |result|
    puts "title: #{title}"
  end

  results = results.next_page
end
```

It seems incredibly unlikely that a developer would ever use `prev_page`, but it's still there if you need it.

Because there may be cases where a developer may need a specific page, the `go_to_page` method also exists. Consider an example where you batch-process books into your own database (which is probably against Copyright laws, but you don't seem to care...):

```ruby
results = ISBNdb::Query.find_books_by_title("ruby")
results = results.go_to_page(50) # where 50 is the page number you want
```

**Note**: `go_to_page`, `next_page` and `prev_page` return `nil` if the `ResultSet` is out of `Result` objects. If you try something like `results.next_page.next_page`, you could get a whiny nil. Think `LinkedLists` when working with `go_to_page`, `next_page` and `prev_page`.

**BIGGER NOTE**: `go_to_page`, `next_page` and `prev_page` BOTH make a subsequent call to the API, using up one of your 500 daily request limits. Please keep this in mind!

Advanced Key Management
-----------------------
As over version 2.0, all access key management has moved into the `config/isbndb.yml` file. ISBNdb will auto-rollover if you specify multiple keys.

Statistics
----------
Ruby ISBNdb now supports basic statistics (from the server):

```ruby
ISBNdb::Query.keystats # => {:requests => 50, :granted => 49}
ISBNdb::Query.keystats[:granted] # => 49
```

**Note**: Ironically, this information also comes from the server, so it counts as a request...

Exceptions
----------
Ruby ISBNdb could raise the following possible exceptions:

```ruby
ISBNdb::AccessKeyError
```

You will most likely encounter `ISBNdb::AccessKeyError` when you have reached your 500-request daily limit. `ISBNdb::InvalidURIError` usually occurs when using magic finder methods with typographical errors.

A Real-Life Example
-------------------
Here is a real-life example of how to use Ruby ISBNdb. Imagine a Rails application that recommends books. You have written a model, `Book`, that has a variety of methods. One of those class methods, `similar`, returns a list of book isbn values that are similar to the current book. Here's how one may do that:

```ruby
# books_controller.rb
def simliar
  @book = Book.find(params[:id])
  @query = ISBNdb::Query.new(['API-KEY-1', 'API-KEY-2'])
  @isbns = @book.similar # returns an array like [1234567890, 0987654321, 3729402827...]

  @isbns.each do |isbn|
    begin
      (@books ||= []) << ISBNdb::Query.find_book_by_isbn(isbn).first
    rescue ISBNdb::AccessKeyError
      SomeMailer.send_limit_email.deliver!
    end
  end
end
```

```ruby
# similar.html.erb
<h1>The following books are recommeded for you:</h1>
<% @books.each do |book| %>
  <div class="book">
    <h2><%= book.title_long %></h2>
    <p><strong>authors</strong>: <%= book.authors_text %></p>
  </div>
<% end %>
```

Testing
-------
[![Build Status](http://travis-ci.org/sethvargo/isbndb.png)](http://travis-ci.org/sethvargo/isbndb)

Change Log
----------
2012-6-17 - Released v2.0
2011-3-11 - Officially changed from ruby_isbndb to isbndb with special thanks to [Terje Tjervaag](https://github.com/terje) for giving up the gem name :)

Acknowledgments
----------------
Special thanks to Terje Tjervaag (https://github.com/terje) for giving up the gem name 'isbndb'!

Special thanks to Lazlo (https://github.com/lazlo) for forwarding his project here!
