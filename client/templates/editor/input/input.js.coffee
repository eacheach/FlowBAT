Template.input.helpers
  placeholder: ->
    @placeholder or i18n.t(@placeholderI18n)
  disabled: ->
    not (if _.isBoolean(@enabled) then @enabled else true)

Template.input.rendered = ->
  editor = @firstNode
  $editor = $(editor)
  editor = share.EditorCache.editors[@data.family]
  if editor.isEditedProperty(@data._id, @data.property)
    $activeElement = $(document.activeElement)
    if $editor.get(0) isnt document.activeElement and (not $activeElement.closest("textarea, input").length or $activeElement.attr("data-family") and $activeElement.attr("data-family") is $editor.attr("data-family"))
      if @data.isNew
        $editor.select()
      else
        $editor.focusToEnd()

Template.input.events
  "focus .property-editor": encapsulate (event, template) ->
    editor = share.EditorCache.editors[template.data.family]
    editor.setEditingProperty(template.data._id, template.data.property)
  "keydown .property-editor": encapsulate (event, template) ->
    $editor = $(event.target)
    editor = share.EditorCache.editors[template.data.family]
    data = template.data
    switch event.keyCode
      when 13 # Enter
        editor.saveProperty(template.data._id, template.data.property, $editor.val())
      when 27 # Escape
        event.preventDefault()
        editor.stopEditing(data._id)
      else
      # noop
  "keyup .property-editor, paste .property-editor": (event, template) ->
    $editor = $(event.target)
    editor = share.EditorCache.editors[template.data.family]
    switch event.keyCode
      when 13 # Enter
        # handled in keydown
      else
        editor.debouncedSaveProperty(template.data._id, template.data.property, $editor.val())
