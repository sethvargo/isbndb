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
    def initialize(json = {})
      @store = build_result(json)
    end

    # Because a result may or may not contain a specified key, we always return nil for
    # consistency. This allows developers to easily check for .nil? instead of checking for
    # a myriad of exceptions throughout their code.
    def method_missing(m, *args, &block)
      @store[m.to_s.underscore]
    end

    # Return a list of all "methods" this class responds to
    def instance_methods
      @store.collect{ |key,value| key.to_s }
    end

    # Pretty print the Result including the number of singleton methods that exist. If
    # you want the ACTUAL singleton methods, call @result.singleton_methods.
    def to_s
      "#<Result @num_singleton_methods=#{@store.size}>"
    end

    def inspect
      "#<Result #{@store.collect{ |key,value| ':' + key.to_s + ' => ' + value.inspect }.join(', ')}>"
    end

    def ==(result)
      self.inspect == result.inspect
    end

    private
    def build_result(json)
      result = {}

      json.each do |key,value|
        result[key.to_s.underscore] = if value.is_a?(Hash)
          build_result(value)
        elsif value.blank?
          nil
        else
          value
        end
      end

      result
    end
  end
end
