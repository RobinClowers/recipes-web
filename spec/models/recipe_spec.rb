require 'spec_helper'

describe Recipe do
  let!(:recipe) do
    Recipe.create!(
      title: 'test',
      description: 'recipe',
      tags: ['tag a', 'tag b'])
  end

  it "can save and load" do
    loaded = Recipe.first
    loaded.title.should == recipe.title
    loaded.description.should == recipe.description
    loaded.tags.should == recipe.tags
  end
end
