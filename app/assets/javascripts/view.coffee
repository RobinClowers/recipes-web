addTagGroup = (e) ->
  e.preventDefault()
  recipeBook.addTagGroup()

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
  recipeBook.saveRecipe()

deleteRecipe = ->
  recipeBook.deleteRecipe @value

deleteTagGroup = ->
  recipeBook.deleteTagGroup @value

$ ->
  window.recipeBook = new RecipeBook()
  recipeBook.init()
  $("#add-tag-group").click addTagGroup
  $("#edit-tag-groups").click editTagGroups
  $("#show-recipes").click showRecipes
  $("#save").click saveClick
  $("#recipe-list").change ->
    recipeBook.changeRecipe @value

  $("#tag-list").change ->
    recipeBook.filterRecipes @value

  $("#tag-groups").change ->
    recipeBook.changeTagGroup()

  $("#recipe-list").bind "keyup", "del", deleteRecipe
  $("#tag-groups").bind "keyup", "del", deleteTagGroup
  $("#description").wysiwyg initialContent: ""
