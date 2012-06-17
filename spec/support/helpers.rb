module Helpers
  # Stub YAML::load to return the hash of keys that we specify
  def stub_access_keys(*keys)
    YAML.stub(:load) do
      { 'access_keys' => keys }
    end
  end
end
