class window.RecipeBook
  constructor: ->
    @clearForm = ->
      $("#title").val ""
      $("#description").wysiwyg "setContent", ""
      $("#tags").val ""

    @isNewRecipe = ->
      id = parseInt($("#recipe-list").val())
      id is 0

    @newRecipe = ->
      @recipe =
        title: ""
        description: ""
        tags: []

    @getRecipe = (id) ->
      _.find @recipes, (recipe) ->
        recipe.id is id

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
      $.getJSON('/recipes', @loadRecipes)
      $.getJSON('/tag_groups', @loadTagGroups)

    @loadRecipes = (recipes) =>
      @recipes = if recipes then recipes else []
      @newRecipe()
      @buildTagIndex()
      @bindTags()
      @bindList()
      @changeTagGroup()

    @loadTagGroups = (tagGroups) =>
      @tagGroups = if tagGroups then tagGroups else []
      @bindTagGroups()
      @changeTagGroup()
      @initializeTagGroups()

    @buildTagIndex = ->
      @tags = []
      for recipe in @recipes
        for tag in recipe.tags
          @tags.push tag unless _.include(@tags, tag)

    @bindTags = ->
      @buildTagIndex()
      list = $("#tag-list")
      list.find("option").remove()
      list.append $("<option />").val("").text("All")
      $.each @tags, (index, tag) ->
        list.append $("<option />").val(tag).text(tag)

    @isFilterSet = ->
      typeof (@tagFilter) isnt "undefined" and @tagFilter isnt ""

    @bindList = ->
      list = $("#recipe-list")
      @clearForm()
      list.find("option").remove()
      list.append $("<option />").val(0).text("New Recipe")
      list.val 0
      for recipe in @recipes
        if not @isFilterSet() or _.include(recipe.tags, @tagFilter)
          list.append $("<option />").val(recipe.id).text(recipe.title)

    @bindTagGroups = ->
      groups = $("#tag-groups")
      groups.find("option").remove()
      $.each @tagGroups, ->
        groups.append $("<option />").val(@name).text(@name)
      groups.children().first().attr "selected", true

    @bindCurrentTagGroup = ->
      tagList = $("#current-tag-group")
      tagList.find("li").remove()
      for tag in @tags
        tagList.append $("<li>" + tag + "</li>").draggable()  if _.include(@currentTagGroup.tags, tag)

    @bindUngroupedTags = ->
      tagList = $("#ungrouped-tags")
      tagList.find("li").remove()
      for tag in @tags
        tagList.append $("<li>" + tag + "</li>").draggable()  unless _.include(@currentTagGroup.tags, tag)

    @initializeTagGroups = ->
      $(".draggable li").draggable()
      $("#current-tag-group").droppable drop: @groupTag
      $("#ungrouped-tags").droppable drop: @ungroupTag

    @groupTag = (event, ui) =>
      newTag = @cloneTag(ui.draggable)
      $(event.target).append newTag
      @currentTagGroup.tags.push newTag.text()
      @saveCurrentTagGroup()

    @ungroupTag = (event, ui) =>
      newTag = @cloneTag(ui.draggable)
      $(event.target).append newTag
      @currentTagGroup.tags = _.filter(@currentTagGroup.tags, (tag) ->
        tag isnt newTag.text()
      )
      @saveCurrentTagGroup()

    @cloneTag = (tag) ->
      $(tag).remove().clone().removeAttr("style").draggable()

  init: =>
    @load()

  changeRecipe: (id) ->
    if id is '0'
      @clearForm()
      return
    @recipe = @getRecipe(id)
    $("#recipe-list").val id
    $("#title").val @recipe.title
    $("#description").wysiwyg "setContent", @recipe.description
    $("#tags").val @recipe.tags.join(", ")

  filterRecipes: (tag) ->
    @tagFilter = ""  if tag is ""
    @tagFilter = tag
    @bindList()

  changeTagGroup: ->
    groupName = $("#tag-groups option:selected").text()
    @currentTagGroup = _.find(@tagGroups, (group) ->
      group.name is groupName
    )
    @currentTagGroup ||=
      tags: []
    @bindCurrentTagGroup()
    @bindUngroupedTags()

  createTagGroup: (group) ->
    $.post("/tag_groups", tag_group: group, dataType: 'json')

  saveCurrentTagGroup: ->
    $.ajax("/tag_groups/#{@currentTagGroup.id}",
      type: 'put'
      dataType: 'json'
      data: tag_group: @currentTagGroup)

  saveRecipe: ->
    @updateRecipe @recipe
    if @isNewRecipe()
      @recipes.push @recipe
      $.post("/recipes", recipe: @recipe, dataType: 'json')
    else
      $.ajax("/recipes/#{@recipe.id}",
        type: 'put'
        dataType: 'json'
        data: recipe: @recipe)
    @bindList()
    @bindTags()
    @changeRecipe @recipe.id

  deleteRecipe: (id) ->
    if confirm("Are you sure you want to delete this recipe?")
      @recipes = _.filter(@recipes, (recipe) ->
        recipe.id isnt id
      )
      $.ajax(
        url: "/recipes/#{@recipe.id}"
        type: 'DELETE'
        dataType: 'json'
        data: @recipe)
      @bindList()
      @buildTagIndex()
      @bindTags()

  deleteTagGroup: (groupName) ->
    if confirm("Are you sure you want to delete this tag group?")
      @tagGroups = _.filter(@tagGroups, (group) ->
        group.name isnt groupName
      )
      @bindTagGroups()

  addTagGroup: ->
    group =
      name: $("#new-tag-group").val()
      tags: []

    @tagGroups.push group
    @createTagGroup(group)
    @bindTagGroups()
