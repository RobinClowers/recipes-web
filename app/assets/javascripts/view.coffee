addTagGroup = (e) ->
  e.preventDefault()
  tagGroupsController.addTagGroup()

editTagGroups = (e) ->
  e.preventDefault()
  $("#recipe-form").hide()
  $("#tag-group-form").show()

showRecipes = (e) ->
  e.preventDefault()
  $("#tag-group-form").hide()
  $("#recipe-form").show()

saveClick = (e) ->
  e.preventDefault()
  recipesController.saveRecipe()

deleteRecipe = ->
  recipesController.deleteRecipe @value

deleteTagGroup = ->
  tagGroupsController.deleteTagGroup @value

$ ->
  window.recipes = new Recipes()
  window.tagGroups = new TagGroups()
  window.recipesController = new RecipesController(recipes, tagGroups)
  window.tagGroupsController = new TagGroupsController(recipes, tagGroups)
  recipes.load( =>
    tagGroups.load( =>
      recipesController.load()
      tagGroupsController.load()
    )
  )
  $("#add-tag-group").click addTagGroup
  $("#edit-tag-groups").click editTagGroups
  $("#show-recipes").click showRecipes
  $("#save").click saveClick
  $("#recipe-list").change ->
    recipesController.changeRecipe @value

  $("#tag-list").change ->
    recipesController.filterRecipes @value

  $("#tag-groups").change ->
    tagGroupsController.changeTagGroup()

  $("#tag-group-list").change ->
    recipesController.filterTags @value

  $("#recipe-list").bind "keyup", "del", deleteRecipe
  $("#tag-groups").bind "keyup", "del", deleteTagGroup
  $("#description").wysiwyg initialContent: ""
