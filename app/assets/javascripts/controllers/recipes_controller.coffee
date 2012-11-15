class @RecipesController
  constructor: (@recipes, @tagGroups) ->
    @clearForm = ->
      $("#title").val ""
      $("#description").wysiwyg "setContent", ""
      $("#tags").val ""

    @newRecipe = ->
      @recipe =
        id: undefined
        title: ""
        description: ""
        tags: []

    @updateRecipe = (recipe) ->
      recipe.title = $("#title").val()
      recipe.description = $("#description").wysiwyg("getContent")
      recipe.tags = @buildTags()

    @buildTags = ->
      list = $("#tags").val().split(",")
      $.map list, (item, index) ->
        return null  if item is ""
        item.trim()

    @load = =>
      @bindTagGroupList()
      @loadRecipes()

    @loadRecipes = =>
      @newRecipe()
      @bindTags()
      @bindRecipeList()

    @bindTags = ->
      list = $("#tag-list")
      list.find("option").remove()
      list.append $("<option />").val("").text("All")
      for tag in @recipes.allTags()
        if not @isTagFilterSet() or _.include(@tagGroupFilter.tags, tag)
          list.append $("<option />").val(tag).text(tag)
      list.children().first().attr "selected", true

    @bindTagGroupList = ->
      list = $("#tag-group-list")
      list.find("option").remove()
      list.append $("<option />").val("").text("All")
      $.each @tagGroups.all(), (index, group) ->
        list.append $("<option />").val(group.id).text(group.name)
      list.children().first().attr "selected", true

    @isFilterSet = ->
      typeof (@tagFilter) isnt "undefined" and @tagFilter isnt ""

    @isTagFilterSet = ->
      typeof (@tagGroupFilter) isnt "undefined" and @tagGroupFilter isnt ""

    @bindRecipeList = ->
      list = $("#recipe-list")
      @clearForm()
      list.find("option").remove()
      list.append $("<option />").val(0).text("New Recipe")
      list.val 0
      for recipe in @recipes.all()
        if not @isFilterSet() or _.include(recipe.tags, @tagFilter)
          list.append $("<option />").val(recipe.id).text(recipe.title)

  changeRecipe: (id) ->
    if id is '0'
      @clearForm()
      @newRecipe()
      return
    @recipe = @recipes.findById(id)
    $("#recipe-list").val id
    $("#title").val @recipe.title
    $("#description").wysiwyg "setContent", @recipe.description
    $("#tags").val @recipe.tags.join(", ")

  filterRecipes: (tag) ->
    @tagFilter = ""  if tag is ""
    @tagFilter = tag
    @bindRecipeList()

  filterTags: (tagGroupId) ->
    @tagGroupFilter = { tags: [] } if tagGroupId is ""
    @tagGroupFilter = @tagGroups.findById(tagGroupId)
    @bindTags()
    @bindRecipeList()

  saveCurrentTagGroup: ->
    $.ajax("/tag_groups/#{@currentTagGroup.id}",
      type: 'put'
      dataType: 'json'
      data: tag_group: @currentTagGroup)

  saveRecipe: ->
    @updateRecipe @recipe
    @recipes.save(@recipe, =>
      @bindRecipeList()
      @bindTags()
      @changeRecipe @recipe.id
    )

  deleteRecipe: (id) ->
    if confirm("Are you sure you want to delete this recipe?")
      @recipes.deleteById(id, =>
        @bindRecipeList()
        @bindTags()
      )
      @changeRecipe '0'
