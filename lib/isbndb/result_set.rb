module ISBNdb
  
  private
  # The ResultSet is a collection of Result objects with helper methods for pagination. It
  # allows for easy paginating through multiple pages of results as well as jumping to a
  # specific results page.
  class ResultSet
    include Enumerable
    
    # This method creates instance variables for @uri, @collection, and @current_page. It then
    # attempts to parse the XML at the gieven URI. If it cannot parse the URI for any reason,
    # it will raise an ISBNdb::InvalidURIError. Next, the results are checked for an any error
    # messages. An ISBNdb::AccessKeyError will be raised if the results contain any errors.
    # Finally, this method then actually builds the ResultSet.
    def initialize(uri, collection, current_page = 1)
      @uri = uri
      @collection = collection
      @current_page = current_page
      @xml = parse_xml
      
      check_results
      build_results
    end
    
    # Because ResultSet extends Enumerable, we need to define the each method. This allows users
    # to call methods like .first, .last, [5], and .each on the ResultSet, making it behave like
    # a primitive array.
    def each(&block)
      @results.each &block
    end
    
    # Jump to a specific page. This method will return nil if the specified page does not exist.
    def go_to_page(page)
      get_total_pages unless @total_pages
      return nil if page < 1 || page > @total_pages
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
      "#<ResultSet @collection=#{@collection}, total_results=#{@results.size}>"
    end
    
    private
    # Try and parses and returns the XML from the given URI. If the parsing fails for any reason, this method
    # raises ISBNdb::InvalidURIError. 
    def parse_xml
      begin
        LibXML::XML::Parser.file(@uri).parse
      rescue
        raise ISBNdb::InvalidURIError
      end
    end
    
    # Check the results for an error message. If one exists, raise an ISBNdb::AccessKeyError for now. 
    # Currently the API does not differentiate between an overloaded API key and an invalid one
    # (it returns the same exact response), so there only exists one exception for now...
    def check_results
      raise ISBNdb::AccessKeyError unless @xml.find("ErrorMessage").first.nil?
    end
    
    # Iterate over #{@collection}List/#{@collection}Data (ex. BookList/BookData) and build a result with
    # each child. This method works because the API always returns #{@collection}List followed by a subset
    # of #{@collection}Data. These results are all pushed into the @results array for accessing.
    def build_results
      @xml.find("#{@collection}List/#{@collection}Data").collect { |node| (@results ||= []) << Result.new(node) }
    end
    
    # This helper method is mainly designed for use with the go_to_page(page) method. It parses the XML
    # and returns the total number of pages that exist for this result set.
    def get_total_pages
      list = @xml.find("#{@collection}List").first.attributes
      @total_pages = (list['total_results'].to_f/list['page_size'].to_f).ceil
    end
  end
end