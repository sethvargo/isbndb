# require dependencies
require 'libxml'

# private sub-classes
require 'ruby_isbndb/result_set'
require 'ruby_isbndb/result'

module ISBNdb
  class Query
    DEFAULT_COLLECTION = :books
    DEFAULT_RESULTS = :details
    BASE_URL = "http://isbndb.com/api" # without trailing slash!
  
    def initialize(access_key)
      @access_key = access_key.to_s
    end
  
    # generic search method
    # format: @query.find(:collection => 'books', :where => {}, :results => 'details')
    def find(params = {})
      raise "No parameters specified! You must specify at least one parameter!" unless params[:where]
      
      collection = params[:collection] ||= DEFAULT_COLLECTION
      results = params[:results] ||= DEFAULT_RESULTS
      results = [results] unless results.is_a?(Array)
      
      # build the search clause
      searches = []
      params[:where].each_with_index do |(key,val), i|
        searches << "index#{i+1}=#{key.to_s.strip}"
        searches << "value#{i+1}=#{val.to_s.strip}"
      end
    
      # build the URI
      uri = "#{BASE_URL}/#{collection}.xml?access_key=#{@access_key}&results=#{results.join(',')}&#{searches.join('&')}"
      
      return ISBNdb::ResultSet.new(uri, singularize(collection).capitalize)
    end
    
    def method_missing(m, *args, &block)
      m = m.to_s.downcase
      
      if m.match(/find_(.+)_by_(.+)/)
        split = m.split('_', 4)
        collection, search_strs = pluralize(split[1].downcase), [split.last]
        
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
    
    def to_s
      "ISBNdb::Query, @access_key = #{@access_key}"
    end
    
    private
    def pluralize(str)
      return 'categories' if str == 'category'
      return "#{str}s" unless str.split(//).last == 's'
      str
    end
    
    def singularize(str)
      return 'category' if str == 'categories'
      return str[0, str.length-1] if str.split(//).last == 's'
      str
    end
  end
end