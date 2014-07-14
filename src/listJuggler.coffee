(($, document, window) ->

  ALLOWED = ["OL", "UL"]

  # Main jQuery Collection method.
  $.fn.listJuggler = (options) ->
    if options is "destroy"
      $(@selector).trigger "listJuggler-destroy"
      return
    opts = $.extend true, {}, $.fn.listJuggler.defaults, options
    listCache = []
    theItem = null
    lastPosition = null
    @each (i, cont) ->
      tag = $(this).prop "tagName"
      throw "You can only apply this plugin to ordered or unordered lists" if ALLOWED.indexOf(tag) is -1
      listItemTag = "li"
      placeHolderTemplate = "<" + listItemTag + ">&nbsp;</" + listItemTag + ">"
      listTemplate =
        text: ""
        draggedItem: null
        placeHolderItem: null
        position: null
        offset: null
        offsetLimit: null
        scroll: null
        container: cont
        init: ->
          #set options to default values if not set
          #list-id allows reference back to correct list variable instance
          $(@container).data("list-id", i).mousedown(@grabItem).on "listJuggler-destroy", @uninit
          @styleDragHandlers true
          return
        uninit: ->
          theItem = listCache[$(this).data("list-id")]
          $(theItem.container).off("mousedown", theItem.grabItem).off "listJuggler-destroy"
          theItem.styleDragHandlers false
          return
        getItems: ->
          $(@container).children listItemTag
        styleDragHandlers: (cursor) ->
          @getItems().map(->
            (if $(this).is(listItemTag) then this else $(this).find(listItemTag).get())
          ).css "cursor", (if cursor then "pointer" else "")
          return
        grabItem: (evt) ->
          #if not left click or if clicked on excluded element (evt.g. text box) or not a moveable list item return
          return if evt.which isnt 1 or $(evt.target).closest(listItemTag).size() is 0
          evt.preventDefault()
          dragHandle = evt.target
          until $(dragHandle).is(listItemTag)
            return if dragHandle is this
            dragHandle = dragHandle.parentNode
          $dragHandle = $(dragHandle)
          $dragHandle.data "cursor", $dragHandle.css("cursor")
          $dragHandle.css "cursor", "move"
          theItem = listCache[$(this).data("list-id")]
          $listItemContainer = $(theItem.container)
          item = this
          iLikeToMoveItMoveIt = ->
            theItem.dragStart.call item, evt
            $listItemContainer.off "mousemove", iLikeToMoveItMoveIt
            return
          $listItemContainer.mousemove(iLikeToMoveItMoveIt).mouseup ->
            $listItemContainer.off "mousemove", iLikeToMoveItMoveIt
            $dragHandle.css "cursor", $dragHandle.data("cursor")
            return
          return

        dragStart: (evt) ->
          theItem.dropItem() if theItem?.draggedItem?
          theItem = listCache[$(this).data("list-id")]
          theItem.draggedItem = $(evt.target).closest(listItemTag)
          
          #record current position so on dragend we know if the dragged item changed position or not
          theItem.draggedItem.data "original-position", $(this).data("list-id") + "-" + theItem.getItems().index(theItem.draggedItem)
          
          #calculate mouse offset relative to draggedItem
          mt = parseInt(theItem.draggedItem.css("marginTop"))
          ml = parseInt(theItem.draggedItem.css("marginLeft"))
          theItem.offset = theItem.draggedItem.offset()
          theItem.offset.top = evt.pageY - theItem.offset.top + ((if isNaN(mt) then 0 else mt)) - 1
          theItem.offset.left = evt.pageX - theItem.offset.left + ((if isNaN(ml) then 0 else ml)) - 1
          
          $listItemContainer = $(theItem.container)
          containerHeight = if $listItemContainer.outerHeight() is 0
            Math.max(1, Math.round(0.5 + theItem.getItems().size() * theItem.draggedItem.outerWidth() / $listItemContainer.outerWidth())) * theItem.draggedItem.outerHeight()
          else
            $listItemContainer.outerHeight()
          theItem.offsetLimit = $listItemContainer.offset()
          theItem.offsetLimit.right = theItem.offsetLimit.left + $listItemContainer.outerWidth() - theItem.draggedItem.outerWidth()
          theItem.offsetLimit.bottom = theItem.offsetLimit.top + containerHeight - theItem.draggedItem.outerHeight()
          
          #create placeholder item
          h = theItem.draggedItem.height()
          w = theItem.draggedItem.width()
          theItem.draggedItem.after placeHolderTemplate
          theItem.placeHolderItem = theItem.draggedItem.next().css(
            height: h
            width: w
          ).data "is-placeholder", true
          
          originalStyle = theItem.draggedItem.attr "style"
          theItem.draggedItem.data "original-style", (if originalStyle then originalStyle else "")
          theItem.draggedItem.css
            position: "absolute"
            opacity: 0.8
            "z-index": 999
            height: h
            width: w

          #auto-scroll setup
          theItem.scroll =
            moveX: 0
            moveY: 0
            maxX: $(opts.document).width() - $(opts.window).width()
            maxY: $(opts.document).height() - $(opts.window).height()

          theItem.scroll.scrollY = opts.window.setInterval(->
            t = $(opts.window).scrollTop()
            if theItem.scroll.moveY > 0 and t < theItem.scroll.maxY or theItem.scroll.moveY < 0 and t > 0
              $(opts.window).scrollTop t + theItem.scroll.moveY
              theItem.draggedItem.css "top", theItem.draggedItem.offset().top + theItem.scroll.moveY + 1
            return
          , 10)
          theItem.scroll.scrollX = opts.window.setInterval(->
            l = $(opts.window).scrollLeft()
            if theItem.scroll.moveX > 0 and l < theItem.scroll.maxX or theItem.scroll.moveX < 0 and l > 0
              $(opts.window).scrollLeft l + theItem.scroll.moveX
              theItem.draggedItem.css "left", theItem.draggedItem.offset().left + theItem.scroll.moveX + 1
            return
          , 10)
          
          $(listCache).each (i, l) ->
            l.buildPositionTable()
            return

          theItem.setPos evt.pageX, evt.pageY
          $(opts.document).on "mousemove", theItem.swapItems
          $(opts.document).on "mouseup", theItem.dropItem
          return

        
        #set position of draggedItem
        setPos: (x, y) ->
          top = Math.min(@offsetLimit.bottom,
                          Math.max(y - @offset.top,
                                    @offsetLimit.top))
          left = Math.min(@offsetLimit.right,
                          Math.max(x - @offset.left,
                                    @offsetLimit.left))
          
          # adjust top, left calculations to parent element instead of 
          # opts.window if it's relative or absolute
          @draggedItem.parents().each ->
            if $(this).css("position") isnt "static" and $(this).css("display") isnt "table"
              offset = $(this).offset()
              top -= offset.top
              left -= offset.left
              false

          #set x or y auto-scroll amount
          y -= $(opts.window).scrollTop()
          x -= $(opts.window).scrollLeft()
          y = Math.max(0, y - $(opts.window).height() + 5) + Math.min(0, y - 5)
          x = Math.max(0, x - $(opts.window).width() + 5) + Math.min(0, x - 5)
          theItem.scroll.moveX = (if x is 0 then 0 else x * 5 / Math.abs(x))
          theItem.scroll.moveY = (if y is 0 then 0 else y * 5 / Math.abs(y))
          
          #move draggedItem to new mouse cursor location
          @draggedItem.css
            top: top
            left: left
          return

        #build a table recording all the positions of the moveable list items
        buildPositionTable: ->
          position = []
          @getItems().not([
            theItem.draggedItem[0]
            theItem.placeHolderItem[0]
          ]).each (i) ->
            $this = $(this)
            loc = $this.offset()
            loc.right = loc.left + $this.outerWidth()
            loc.bottom = loc.top + $this.outerHeight()
            loc.elm = this
            position[i] = loc
            return
          @position = position
          return

        dropItem: ->
          return  unless theItem.draggedItem?
          
          originalStyle = theItem.draggedItem.data "original-style"
          theItem.draggedItem.attr "style", originalStyle
          theItem.draggedItem.removeAttr "style"  if originalStyle is ""
          theItem.draggedItem.removeData "original-style"
          theItem.styleDragHandlers true
          theItem.placeHolderItem.before theItem.draggedItem
          theItem.placeHolderItem.remove()
          $(":data(droptarget)").remove()
          opts.window.clearInterval theItem.scroll.scrollY
          opts.window.clearInterval theItem.scroll.scrollX
          
          #if position changed call callback
          opts.callback(theItem.draggedItem, cont) unless theItem.draggedItem.data("original-position") is $(listCache).index(theItem) + "-" + theItem.getItems().index(theItem.draggedItem)
          theItem.draggedItem.removeData "original-position"
          theItem.draggedItem = null
          $(opts.document).off "mousemove", theItem.swapItems
          $(opts.document).off "mouseup", theItem.dropItem
          false

        #swap the draggedItem (represented visually by placeholder) with the list item the it has been dragged on top of
        swapItems: (evt) ->
          return false unless theItem.draggedItem?
          
          #move draggedItem to mouse location
          theItem.setPos evt.pageX, evt.pageY
          
          #retrieve list and item position mouse cursor is over
          listIndex = theItem.findPosition(evt.pageX, evt.pageY)
          aList = theItem
          return false if listIndex is -1
          
          #save fixed items locations
          children = ->
            $(aList.container).children().not aList.draggedItem

          fixed = children().not(listItemTag).each ->
            @fixedIndex = children().index this
            return

          #if moving draggedItem up or left place placeHolder before list item the dragged item is hovering over otherwise place it after
          if not lastPosition? or lastPosition.top > theItem.draggedItem.offset().top or lastPosition.left > theItem.draggedItem.offset().left
            $(aList.position[listIndex].elm).before theItem.placeHolderItem
          else
            $(aList.position[listIndex].elm).after theItem.placeHolderItem
          
          #restore fixed items location
          fixed.each ->
            elm = children().eq(@fixedIndex).get(0)
            if this isnt elm and children().index(this) < @fixedIndex
              $(this).insertAfter elm
            else $(this).insertBefore elm  unless this is elm
            return

          $(listCache).each (i, l) ->
            l.buildPositionTable()
            return

          lastPosition = theItem.draggedItem.offset()
          false

        #returns the index of the item that the mouse is over
        findPosition: (x, y) ->
          i = 0
          while i < @position.length
            return i if @position[i].left < x and @position[i].right > x and @position[i].top < y and @position[i].bottom > y
            i = i + 1
          return -1

      listTemplate.init()
      listCache.push listTemplate
      return

    return this

  $.fn.listJuggler.defaults =
    callback: ->
      return
    document: document
    window: window

  return
) jQuery, self.document, self
