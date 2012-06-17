module ISBNdb
  # The Query object is the most important class of the ISBNdb Module. It is the only public
  # class, and handles the processing power.
  class Query
    include HTTParty
    base_uri 'http://isbndb.com/api'
    headers 'Content-Type' => 'text/xml'

    # This is the generic find method. It accepts a hash of parameters including :collection,
    # :where clauses, and :results to show. It builds the corresponding URI and sends that URI
    # off to the ResultSet for processing.
    def self.find(params = {})
      raise 'No parameters specified! You must specify at least one parameter!' unless params[:where]
      raise 'params[:where] cannot be a String! It must be a Hash!' if params[:where].is_a?(String)
      raise 'params[:where] cannot be an Array! It must be a Hash!' if params[:where].is_a?(Array)

      collection = params[:collection] ||= :books
      results = params[:results] ||= :details
      results = [results].flatten

      # build the search clause
      searches = []
      params[:where].each_with_index do |(key,val), i|
        searches << "index#{i+1}=#{key.to_s.strip}"
        searches << "value#{i+1}=#{val.to_s.strip}"
      end

      # make the request
      uri = "/#{collection}.xml?access_key=#{access_key_set.current_key}&results=#{results.join(',')}&#{searches.join('&')}"
      ISBNdb::ResultSet.new(uri, collection)
    rescue ISBNdb::AccessKeyError
      access_key_set.next_key!
      retry unless access_key_set.current_key.nil?
      raise
    end

    # This method returns keystats about your API key, including the number of requests
    # and the number of granted requets. Be advised that this request actually counts
    # as a request to the server, so use with caution.
    def self.keystats
      result = self.get("/books.xml?access_key=#{access_key_set.current_key}&results=keystats")
      result.parsed_response['ISBNdb']['KeyStats'] || {}
    end

    # Method missing allows for dynamic finders, similar to that of ActiveRecord. See
    # the README for more information on using magic finders.
    def self.method_missing(m, *args, &block)
      method = m.to_s.downcase

      if method.match(/find_(.+)_by_(.+)/)
        split = method.split('_', 4)
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
    def self.to_s
      "#<ISBNdb::Query, @access_key=#{access_key_set.current_key}>"
    end

    private
    def self.access_key_set
      @@access_key_set ||= ISBNdb::AccessKeySet.new
    end
  end
end
