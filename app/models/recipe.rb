class Recipe
  include MongoMapper::Document

  key :title, String
  key :description, String
  key :tags, Set
end
