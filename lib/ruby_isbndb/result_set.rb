module ISBNdb
  private
  class ResultSet
    include Enumerable
    
    def initialize(uri, collection, current_page = 1)
      xml = LibXML::XML::Parser.file(uri).parse
      @uri, @collection, @current_page, @results = uri, collection, current_page, []
      @total_pages = get_total_number_of_pages(xml)
      build_results(xml)
    end
    
    def each(&block)
      @results.each &block
    end
    
    def go_to_page(page)
      return nil if page < 1 || page > @total_pages
      ISBNdb::ResultSet.new("#{@uri}&page_number=#{page}", @collection, page)
    end
    
    def next_page
      go_to_page(@current_page+1)
    end
    
    def prev_page
     go_to_page(@current_page-1)
    end
    
    def to_s
      "#<ResultSet @collection=#{@collection}>"
    end
    
    private
    def get_total_number_of_pages(xml)
      list = xml.find("#{@collection}List")
      node = list.first
      (node.attributes['total_results'].to_f/node.attributes['page_size'].to_f).ceil
    end
    
    def build_results(xml)
      xml.find("#{@collection}List/#{@collection}Data").collect { |node| @results << Result.new(node) }
    end
  end
end