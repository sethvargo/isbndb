module ISBNdb
  private
  class Result
    def initialize(top_node)
      build_result(top_node)
    end
    
    def build_result(top_node)
      top_node.attributes.each do |attribute|
        singleton.send(:define_method, formatted_method_name(attribute.name)) { attribute.value } unless attribute.value.strip.empty?
      end
      
      if top_node.children?
        top_node.children.each { |child| build_result(child) }
      else
        singleton.send(:define_method, formatted_method_name(top_node.parent.name)) { top_node.content.strip.chomp(',') } unless top_node.content.strip.empty?
      end
    end
    
    def method_missing(m, *args, &block)
      nil
    end
    
    def to_s
      "#<Result>"
    end
    
    private
    def formatted_method_name(name)
      camel_to_underscore(name.strip).to_sym
    end
    
    def camel_to_underscore(str)
      str.gsub(/(.)([A-Z])/,'\1_\2').downcase
    end
    
    def singleton
      class << self; self end
    end
  end
end