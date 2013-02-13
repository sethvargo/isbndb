require 'spec_helper'

describe 'foo' do
  context 'x' do
    p ISBNdb::Subject.find_by_name('Rails', :access_key => '83QHZBIK')
  end
end
