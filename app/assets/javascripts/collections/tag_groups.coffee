class @TagGroups
  constructor: ->
    @loadTagGroups = (tagGroups) ->
      @groups = if tagGroups then tagGroups else []

  load: (done) ->
    $.getJSON('/tag_groups', (tagGroups) =>
      @loadTagGroups(tagGroups)
      done()
    )

  all: ->
    @groups

  findById: (id) ->
    _.find(@groups, (group) ->
      group.id is id
    )

  create: (group) ->
    @groups.push group
    $.ajax("/tag_groups/",
      type: 'post'
      dataType: 'json'
      data: tag_group: group
      success: (newGroup) =>
        group.id = newGroup.id
    )

  update: (group) ->
    $.ajax("/tag_groups/#{group.id}",
      type: 'put'
      dataType: 'json'
      data: tag_group: group)

  deleteByName: (groupName) ->
    id = _.find(@groups, (group) ->
      group.name is groupName
    ).id
    $.ajax(
      url: "/tag_groups/#{id}"
      type: 'DELETE'
      dataType: 'json'
      data: @recipe)
    @groups = _.filter(@groups, (group) ->
      group.name isnt groupName
    )

