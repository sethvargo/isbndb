module ISBNdb
  
  private
  # The Result object is a true testament of metaprogramming. Almost every method of the Result
  # is dynamically generated through the build_result() method. All attribtues of the XML are
  # parsed, translated, and populated as instance methods on the Result object. This allows for
  # easy Ruby-like access (@book.title), without hardcoding every single possible return value
  # from the ISBNdb API
  class Result
    # Initialize simply calls build_result. Because the method definition is recusive, it must
    # be moved into a separate helper.
    def initialize(top_node)
      build_result(top_node)
    end
    
    # Because a result may or may not contain a specified key, we always return nil for 
    # consistency. This allows developers to easily check for .nil? instead of checking for
    # a miriad of exceptions throughout their code.
    def method_missing(m, *args, &block)
      nil
    end
    
    # Pretty preint the Result including the number of singleton methods that exist. If
    # you want the ACTUAL singleton methods, call @result.singleton_methods.
    def to_s
      @singleton_methods ||= []
      "#<Result @num_singleton_methods=#{@singleton_methods.size}>"
    end
    
    private
    # This is the `magical` method. It essentially parses each attribute of the XML as well as
    # the content of each XML node, dynamically sends a method to the instance with that attribute's
    # or content's value. Not to be outdone, it recursively iterates over all children too!
    def build_result(top_node)
      top_node.attributes.each do |attribute|
        singleton.send(:define_method, method_name(attribute.name)) { attribute.value } unless attribute.value.strip.empty?
      end
      
      if top_node.children?
        top_node.children.each { |child| build_result(child) }
      else
        singleton.send(:define_method, method_name(top_node.parent.name)) { top_node.content.strip.chomp(',') } unless top_node.content.strip.empty?
      end
    end
    
    # This helper function reduces code redundancy and maintains consistency by formatting
    # all method names the same. All method names are stripped of any trailing whitespaces,
    # converted from CamelCase to under_score, and converted to a symbol 
    def method_name(name)
      name.strip.underscore.to_sym
    end
    
    # We need a singleton reference to the current _instance_ so that we can dynamically define
    # methods. This is just a simple helper that returns the singleton class of the current
    # object instance.
    def singleton
      class << self; self end
    end
  end
end