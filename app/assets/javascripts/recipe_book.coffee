class window.RecipeBook
  constructor: ->
    @clearForm = ->
      $("#title").val ""
      $("#description").wysiwyg "setContent", ""
      $("#tags").val ""

    @currentId = ->
      id = parseInt($("#recipe-list").val())
      id is 0

    @isNewRecipe = ->
      id = parseInt($("#recipe-list").val())
      id is 0

    @newRecipe = ->
      @recipe =
        id: @getNextId()
        name: ""
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

    @getNextId = ->
      return 1  if @recipes.length is 0
      @recipes[@recipes.length - 1].id + 1

    @load = =>
      fileContents = $.twFile.load(@filePath)
      console.log "file contents: " + fileContents
      if fileContents
        data = JSON.parse(fileContents)
        @recipes = data.recipes
        @tagGroups = data.tagGroups
      else
        @recipes = []
        @tagGroups = []
      console.log @recipes
      @newRecipe()
      @buildTagIndex()
      @bindTags()
      @bindList()
      @bindTagGroups()
      @changeTagGroup()
      @initializeTagGroups()

    @buildTagIndex = ->
      @tags = []
      $.each @recipes, (index, recipe) ->
        $.each recipe.tags, (tagIndex, tag) ->
          @tags.push tag  unless _.include(@tags, tag)

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
      noFilter = not @isFilterSet()
      tagFilter = @tagFilter
      $.each @recipes, ->
        list.append $("<option />").val(@id).text(@title)  if noFilter or _.include(@tags, tagFilter)

    @bindTagGroups = ->
      groups = $("#tag-groups")
      groups.find("option").remove()
      $.each @tagGroups, ->
        groups.append $("<option />").val(@name).text(@name)
      groups.children().first().attr "selected", true

    @bindCurrentTagGroup = ->
      tagList = $("#current-tag-group")
      tagList.find("li").remove()
      _.each @tags, (tag) ->
        tagList.append $("<li>" + tag + "</li>").draggable()  if _.include(@currentTagGroup.tags, tag)

    @bindUngroupedTags = ->
      tagList = $("#ungrouped-tags")
      tagList.find("li").remove()
      _.each @tags, (tag) ->
        tagList.append $("<li>" + tag + "</li>").draggable()  unless _.include(@currentTagGroup.tags, tag)

    @initializeTagGroups = ->
      $(".draggable li").draggable()
      $("#current-tag-group").droppable drop: @groupTag
      $("#ungrouped-tags").droppable drop: @ungroupTag

    @groupTag = (event, ui) ->
      newTag = cloneTag(ui.draggable)
      $(this).append newTag
      @currentTagGroup.tags.push newTag.text()
      save()

    @ungroupTag = (event, ui) ->
      newTag = cloneTag(ui.draggable)
      $(this).append newTag
      @currentTagGroup.tags = _.filter(@currentTagGroup.tags, (tag) ->
        tag isnt newTag.text()
      )
      save()

    @cloneTag = (tag) ->
      $(tag).remove().clone().removeAttr("style").draggable()

    @save = ->
      data =
        recipes: @recipes
        tagGroups: @tagGroups

      jsonData = JSON.stringify(data, null, 2)
      $.twFile.save @filePath, jsonData

  init: =>
    filePath = document.location.href
    filePath = $.twFile.convertUriToLocalPath(filePath)
    filePath = filePath.replace(/index.html/, "")
    @filePath = filePath + "data.json"
    @load()

  changeRecipe: (id) ->
    if id is 0
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
    @bindCurrentTagGroup()
    @bindUngroupedTags()

  saveRecipe: ->
    @recipes.push @recipe  if @isNewRecipe()
    @updateRecipe @recipe
    save()
    @bindList()
    @bindTags()
    @changeRecipe @recipe.id

  deleteRecipe: (id) ->
    if confirm("Are you sure you want to delete this recipe?")
      @recipes = _.filter(@recipes, (recipe) ->
        recipe.id isnt id
      )
      @save()
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
    @save()
    @bindTagGroups()
