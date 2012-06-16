module ISBNdb

  private
  # The AccessKeySet is a simple class used to manage access keys. It is used primarily
  # by the ruby_isbndb class to automatically advance access keys when necessary.
  class AccessKeySet
    # Create the @access_keys array and then verify that the keys are valid keys.
    def initialize(access_keys)
      @access_keys = [access_keys].flatten
    end

    # Returns the total number of access keys in this set.
    def size
      @access_keys.size
    end

    # Get the current key. It returns a string of the access key.
    def current_key
      @access_keys[@current_index ||= 0]
    end

    # Move the key pointer forward.
    def next_key!
      @current_index += 1
    end

    # Get the next key.
    def next_key
      @access_keys[@current_index+1]
    end

    # Move the key pointer back.
    def prev_key!
      @current_index -= 1
    end

    # Get the previous key.
    def prev_key
      @access_keys[@current_index-1]
    end

    # Tell Ruby ISBNdb to use a specified key. If the key does not exist, it is
    # added to the set and set as the current key.
    def use_key(key)
      @current_index = @access_keys.index(key) || @access_keys.push(key).index(key)
    end

    # Remove the given access key from the AccessKeySet.
    def remove_key(key)
      @access_keys.delete(key)
    end

    # Pretty print the AccessKeySet
    def to_s
      "#<AccessKeySet @keys=<#{@access_keys.collect{ |key| key }.join(',')}>>"
    end
  end
end
