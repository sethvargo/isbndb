module ISBNdb
  module Base
    module ClassMethods
      def argument(name, options = {})
        arguments[name.to_sym] = options
      end

      def result(name, options = {})
        results[name.to_sym] = options
      end

      def find(value)
        default = default_results.first

        if default.nil?
          raise ISBNdb::NoDefaultSpecified, "You did not specify a default attribute for #{self.to_s}!"
        end

        where(default => value)
      end

      def where(conditions = {})
        raise ArgumentError, "#{self.to_s}.where cannot be an Array, it must be a Hash!" if conditions.is_a?(Array)
        raise ArgumentError, "#{self.to_s}.where cannot be a String, it must be a Hash!" if conditions.is_a?(String)

        conditions.reverse_merge!(results: @default_results, access_key: @f)

        request build_querystring(conditions)
      end

      def request(querystring, options = {})
        options.reverse_merge!('Content-Type' => 'text/xml')

        begin
          response = HTTParty.get("http://isbndb.com/api/#{collection}.xml?" + querystring, options).parsed_response
          if response['ISBNdb']
            @result = normalize_keys(response['ISBNdb'])
            @meta = @result[list_key]
            @data = @meta.delete(data_key)
          else
            raise ArgumentError, "Malformed hash."
          end
        rescue Exception => e
          p e
        end
      end

      def respond_to?(method)
        if method.to_s =~ /^find_by_(.+)$/
          $1.split('_and_').map(&:to_sym).all?{ |key| arguments.keys.include?(key) }
        else
          super
        end
      end

      def method_missing(method, *args, &block)
        if method.to_s =~ /^find_by_(.+)$/
          run_find_by_method($1, *args, &block)
        else
          super
        end
      end

      protected
      def arguments
        @arguments ||= {}
      end

      def default_arguments
        @default_arguments ||= arguments.select{ |argument, options| options[:default] }.keys
      end

      def results
        @results ||= {}
      end

      def default_results
        @default_results ||= results.select{ |result, options| options[:default] }.keys
      end

      def run_find_by_method(keys, *args, &block)
        # Extract any additional options passed to the method, like :results => 'foo'
        options = args.extract_options!

        # Make an array of attribute names
        keys = keys.split('_and_').map(&:to_sym)

        # Make sure these are valid arguments
        mismatched_keys = keys - arguments.keys
        unless mismatched_keys.empty?
          raise ISBNdb::UnknownAttribute, "Invalid attribute(s) #{mismatched_keys.map{|k| "'#{k}'"}.to_sentence} for #{self.to_s}!"
        end

        # #transpose will zip the two arrays together like so:
        #   [[:a, :b, :c], [1, 2, 3]].transpose
        #   # => [[:a, 1], [:b, 2], [:c, 3]]
        keys_with_args = [keys, args].transpose

        # Hash[] will take the passed associative array and turn it
        # into a hash like so:
        #   Hash[[[:a, 2], [:b, 4]]] # => { :a => 2, :b => 4 }
        conditions = Hash[keys_with_args]

        # #where and #all are new AREL goodness that will find all
        # records matching our conditions
        where(options.merge(conditions))
      end

      # Given a hash of conditions, build the querystring parameters that
      # will be appended to the request.
      #
      # @example
      #   build_querystring({:title => 'Rails'}) #=> 'index1=title&value1=Rails'
      #
      # @param [Hash] conditions
      #   the conditions to turn into a querystring
      # @return [String]
      #   the querystring
      def build_querystring(conditions = {})
        results = [conditions.delete(:results) || default_results].flatten.join(',')
        access_key = conditions.delete(:access_key) || @current_access_key

        query = conditions.collect.with_index do |(key,val), i|
          [ "index#{i+1}=#{key}", "value#{i+1}=#{val}" ]
        end.flatten.join('&')

        return "access_key=#{access_key}&results=#{results}&#{query}"
      end

      def model
        @model ||= self.name.demodulize.underscore
      end

      def collection
        @collection ||= model.pluralize
      end

      def list_key
        @list_key ||= "#{model}_list".to_sym
      end

      def data_key
        @data_key ||= "#{model}_data".to_sym
      end

      # Given a mixed hash of varying keys, depth, and casing, convert
      # all keys to lowercase, underscored symbols for normalization.
      #
      # This method also attempts to convert non-leading-zero string-numbers
      # into their Fixnum counterparts.
      #
      # @example Basic Usage
      #   normalize_keys('Foo' => 'bar', :zip => 'zap') #=> { :foo => 'bar', :zip => 'zap' }
      #
      # @example CaMeLCaSeD to under_score
      #   normalize_keys('FooBar' => 'a', :zip => 'zap') #=> { :foo_bar => 'a', :zip => 'zap' }
      #
      # @example Deeply Nested
      #   normalize_keys('FooBar' => 'a', 'Zip' => { 'MagicList' => ['zop', 'zil'] }) #=> { :foo_bar => 'a', :zip => { :magic_list => ['zap', 'zil'] } }
      #
      # @example Integer => Strings
      #   normalize_keys({ :foo => '123', :zip => '0456' }) #=> { :foo => 123, :zip => '0456' }
      #
      # @return [Hash]
      #   A new hash with normalized keys, attributes, and integer-like values.
      def normalize_keys(hash)
        hash.dup.inject({}) do |result, (key, value)|
          result[(key.to_s.underscore.to_sym rescue key)] = case value
          when Hash
            normalize_keys(value)
          when Array
            value.dup.map{ |a| normalize_keys(a) }
          when String
            tmp = value.dup.strip.presence
            # Convert non-zero padded string integers to integers
            tmp =~ /^[1-9]+\d*$/ ? tmp.to_i : tmp
          else
            value.dup.presence
          end

          result
        end
      end
    end

    module InstanceMethods
      def initialize(hash = {})

      end

      %w(model collection list_key data_key).each do |method|
        define_method method do
          self.class.send(method)
        end
      end
    end

    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end
  end
end
