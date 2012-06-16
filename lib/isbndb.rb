# require dependencies
require 'active_support/inflector'

# private sub-classes
require 'isbndb/access_key_set'
require 'isbndb/exceptions'
require 'isbndb/result_set'
require 'isbndb/result'

require 'core_extensions/string'

module ISBNdb
  # The Query object is the most important class of the ISBNdb Module. It is the only public
  # class, and handles the processing power.
  class Query
    DEFAULT_COLLECTION = :books
    DEFAULT_RESULTS = :details
    BASE_URL = "http://isbndb.com/api"

    # Access methods of the access_key_set instance variable. This allows developers to manually
    # advance, add, remove, and manage keys. See the AccessKeySet class for more information.
    attr_reader :access_key_set

    # This method sets an array of access_keys to use for making requests to the ISBNdb API.
    def initialize(access_keys)
      @access_key_set = ISBNdb::AccessKeySet.new(access_keys)
    end

    # This is the generic find method. It accepts a hash of parameters including :collection,
    # :where clauses, and :results to show. It builds the corresponding URI and sends that URI
    # off to the ResultSet for processing.
    def find(params = {})
      raise "No parameters specified! You must specify at least one parameter!" unless params[:where]

      collection = params[:collection] ||= DEFAULT_COLLECTION
      results = params[:results] ||= DEFAULT_RESULTS
      results = [results].flatten

      # build the search clause
      searches = []
      params[:where].each_with_index do |(key,val), i|
        searches << "index#{i+1}=#{key.to_s.strip}"
        searches << "value#{i+1}=#{val.to_s.strip}"
      end

      # make the request
      make_request(collection, results, searches)
    end

    # This method returns keystats about your API key, including the number of requests
    # and the number of granted requets. Be advised that this request actually counts
    # as a request to the server, so use with caution.
    def keystats
      uri = "#{BASE_URL}/books.xml?access_key=#{@access_key_set.current_key}&results=keystats"
      keystats = {}
      LibXML::XML::Parser.file(uri).parse.find('KeyStats').first.attributes.each { |attribute| keystats[attribute.name.to_sym] = attribute.value.to_i unless attribute.name == 'access_key' }
      return keystats
    end

    # Method missing allows for dynamic finders, similar to that of ActiveRecord. See
    # the README for more information on using magic finders.
    def method_missing(m, *args, &block)
      m = m.to_s.downcase

      if m.match(/find_(.+)_by_(.+)/)
        split = m.split('_', 4)
        collection, search_strs = split[1].downcase.pluralize, [split.last]

        # check and see if we are searching multiple fields
        search_strs = search_strs.first.split('_and_') if(search_strs.first.match(/_and_/))
        raise "Wrong Number of Arguments (#{args.size} for #{search_strs.size})" if args.size != search_strs.size

        # create the searches hash
        searches = {}
        search_strs.each_with_index { |str, i| searches[str.strip.to_sym] = args[i].strip }

        return find(:collection => collection, :where => searches)
      end

      super
    end

    # Pretty print the Query object with the access key.
    def to_s
      "#<ISBNdb::Query, @access_key=#{@access_key_set.current_key}>"
    end

    private
    # Make the request to the ResultSet. If the request fails because of an ISBNdb::AccessKeyError
    # the system will automatically rollover to the next AccessKey in the AccessKeySet. If one exists,
    # a new request is attempted. If not, the ISBNdb::AccessKeyError persists and can be caught by your
    # application logic.
    def make_request(collection, results, searches)
      begin
        uri = "#{BASE_URL}/#{collection}.xml?access_key=#{@access_key_set.current_key}&results=#{results.join(',')}&#{searches.join('&')}"
        ISBNdb::ResultSet.new(uri, collection.singularize.capitalize)
      rescue ISBNdb::AccessKeyError
        puts "Access Key Error (#{@access_key_set.current_key}) - You probably reached your limit! Trying the next key."
        @access_key_set.next_key!
        retry unless @access_key_set.current_key.nil?
        raise ISBNdb::AccessKeyError
      end
    end
  end
end
