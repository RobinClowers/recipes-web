class TagGroup
  include MongoMapper::Document

  key :name, String
  key :tags, Array

end
