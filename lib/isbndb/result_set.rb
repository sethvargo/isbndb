module ISBNdb

  private
  # The ResultSet is a collection of Result objects with helper methods for pagination. It
  # allows for easy paginating through multiple pages of results as well as jumping to a
  # specific results page.
  class ResultSet
    include Enumerable
    include HTTParty

    base_uri 'http://isbndb.com/api'
    headers 'Content-Type' => 'text/xml'

    # This method creates instance variables for @uri, @collection, and @current_page. It then
    # attempts to parse the XML at the gieven URI. If it cannot parse the URI for any reason,
    # it will raise an ISBNdb::InvalidURIError. Next, the results are checked for an any error
    # messages. An ISBNdb::AccessKeyError will be raised if the results contain any errors.
    # Finally, this method then actually builds the ResultSet.
    def initialize(uri, collection, current_page = 1)
      @uri = URI.escape(uri)
      @collection = collection.to_s.titleize.singularize
      @current_page = current_page
      @parsed_response = self.class.get(@uri).parsed_response['ISBNdb']

      check_results
      build_results
    end

    def size
      @results.size
    end

    # Because ResultSet extends Enumerable, we need to define the each method. This allows users
    # to call methods like .first, .last, and .each on the ResultSet, making it behave like
    # a primitive array.
    def each(&block)
      @results.each &block
    end

    # Access via index
    def [](i)
      @results[i]
    end

    # Jump to a specific page. This method will return nil if the specified page does not exist.
    def go_to_page(page)
      get_total_pages unless @total_pages
      return nil if page.to_i < 1 || page.to_i > @total_pages
      ISBNdb::ResultSet.new("#{@uri}&page_number=#{page}", @collection, page)
    end

    # Go to the next page. This method will return nil if a next page does not exist.
    def next_page
      go_to_page(@current_page+1)
    end

    # Go to the previous page. This method will return nil if a previous page does not exist.
    def prev_page
     go_to_page(@current_page-1)
    end

    # Pretty prints the Result set information.
    def to_s
      "#<ResultSet::#{@collection} :total_results => #{@results.size}>"
    end

    def ==(result_set)
      self.size == result_set.size && self.instance_variable_get('@results') == result_set.instance_variable_get('@results')
    end

    private
    # Check the results for an error message. If one exists, raise an ISBNdb::AccessKeyError for now.
    # Currently the API does not differentiate between an overloaded API key and an invalid one
    # (it returns the same exact response), so there only exists one exception for now...
    def check_results
      raise ISBNdb::AccessKeyError if @parsed_response['ErrorMessage']
    end

    # Iterate over #{@collection}List/#{@collection}Data (ex. BookList/BookData) and build a result with
    # each child. This method works because the API always returns #{@collection}List followed by a subset
    # of #{@collection}Data. These results are all pushed into the @results array for accessing.
    def build_results
      result_json = @parsed_response["#{@collection}List"]["#{@collection}Data"]
      if result_json.is_a?(Hash)  ## One result, typically from find_by_isbn
        @results = [Result.new(result_json)]
      else
        @results = (result_json || []).collect{ |json| Result.new(json) }
      end
    end

    # This helper method is mainly designed for use with the go_to_page(page) method. It parses the XML
    # and returns the total number of pages that exist for this result set.
    def get_total_pages
      list = @parsed_response["#{@collection}List"]
      @total_pages = (list['total_results'].to_f/list['page_size'].to_f).ceil
    end
  end
end
