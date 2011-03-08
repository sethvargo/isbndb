module ISBNdb
  private
  class ResultSet
    include Enumerable
    
    def initialize(uri, collection)
      @results = []
      xml = LibXML::XML::Parser.file(uri).parse
      xml.find("#{collection}List/#{collection}Data").collect { |node| @results << Result.new(node) }
    end
    
    def each(&block)
      @results.each &block
    end
    
    def to_s
      @results.collect { |r| r.book_id }.join("\n")
    end
  end
end