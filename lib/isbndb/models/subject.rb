module ISBNdb
  class Subject
    include ISBNdb::Base

    argument :name
    argument :category_id
    argument :subject_id, default: true

    result :categories
    result :structure
  end
end
