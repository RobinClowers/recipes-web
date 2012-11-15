class @Recipes
  constructor: ->
    @loadRecipes = (recipes) ->
      @recipes = if recipes then recipes else []

    @buildTagIndex = ->
      @tags = []
      for recipe in @recipes
        for tag in recipe.tags
          @tags.push tag unless _.include(@tags, tag)

  load: (done) ->
    $.getJSON('/recipes', (recipes) =>
      @loadRecipes(recipes)
      @buildTagIndex()
      done()
    )

  all: ->
    @recipes

  allTags: ->
    @tags

  findById: (id) ->
    _.find(@recipes, (recipe) ->
      recipe.id is id
    )

  save: (recipe, done) ->
    if recipe.id is undefined
      @recipes.push recipe
      $.ajax("/recipes",
        type: 'post'
        dataType: 'json'
        data: recipe: recipe
        success: (newRecipe) =>
          recipe.id = newRecipe.id
          done()
      )
    else
      $.ajax("/recipes/#{recipe.id}",
        type: 'put'
        dataType: 'json'
        data: recipe: recipe
        success: (newRecipe) =>
          done()
      )

  deleteById: (id, done) ->
    @recipes = _.filter(@recipes, (recipe) ->
      recipe.id isnt id
    )
    $.ajax(
      url: "/recipes/#{id}"
      type: 'DELETE'
      dataType: 'json'
      data: @recipe)
    @buildTagIndex()
    done()

