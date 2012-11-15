class @TagGroupsController
  constructor: (@recipes, @tagGroups) ->
    @load = ->
      @bindTagGroups()
      @changeTagGroup()
      @initializeTagGroups()

    @bindTagGroups = ->
      groups = $("#tag-groups")
      groups.find("option").remove()
      $.each @tagGroups.all(), ->
        groups.append $("<option />").val(@name).text(@name)
      groups.children().first().attr "selected", true

    @bindCurrentTagGroup = ->
      tagList = $("#current-tag-group")
      tagList.find("li").remove()
      for tag in @recipes.allTags()
        tagList.append $("<li>" + tag + "</li>").draggable()  if _.include(@currentTagGroup.tags, tag)

    @bindUngroupedTags = ->
      tagList = $("#ungrouped-tags")
      tagList.find("li").remove()
      for tag in @recipes.allTags()
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

  changeTagGroup: ->
    groupName = $("#tag-groups option:selected").text()
    @currentTagGroup = _.find(@tagGroups.all(), (group) ->
      group.name is groupName
    )
    @currentTagGroup ||=
      tags: []
    @bindCurrentTagGroup()
    @bindUngroupedTags()

  saveCurrentTagGroup: ->
    $.ajax("/tag_groups/#{@currentTagGroup.id}",
      type: 'put'
      dataType: 'json'
      data: tag_group: @currentTagGroup)

  deleteTagGroup: (groupName) ->
    if confirm("Are you sure you want to delete this tag group?")
      @tagGroups.deleteByName(groupName)
      @bindTagGroups()

  addTagGroup: ->
    group =
      name: $("#new-tag-group").val()
      tags: []

    @tagGroups.create(group)
    @bindTagGroups()
