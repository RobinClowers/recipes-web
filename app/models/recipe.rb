class Recipe
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

  key :title, String
  key :description, String
  key :tags, Set
end
