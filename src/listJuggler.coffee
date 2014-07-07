(($, document, window) ->

  ALLOWED = ["OL", "UL"]

  # Main jQuery Collection method.
  $.fn.listJuggler = (options) ->
    if options is "destroy"
      $(@selector).trigger "listJuggler-destroy"
      return
    opts = $.extend true, {}, $.fn.listJuggler.defaults, options
    # console.debug "opts", opts
    # console.debug "checking document", document, opts.document, document is opts.document
    # console.debug "checking window", window, opts.window, window is opts.window
    # console.debug "comparing window.document with document", window.document, document, window.document is document
    # console.debug "comparing opts.window.document with opts.document", opts.window.document, opts.document, opts.window.document is opts.document
    listCache = []
    theList = null
    lastPosition = null
    console.debug "this is", @
    @each (i, cont) ->
      tag = $(this).prop "tagName"
      throw "You can only apply this plugin to ordered or unordered lists" if ALLOWED.indexOf(tag) is -1
      listItemTag = "li"
      placeHolderTemplate = "<" + listItemTag + ">&nbsp;</" + listItemTag + ">"
      console.debug "container", cont, "is in iframe's document", $.contains(opts.document, cont)
      listTemplate =
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
          theList = listCache[$(this).data("list-id")]
          $(theList.container).off("mousedown", theList.grabItem).off "listJuggler-destroy"
          theList.styleDragHandlers false
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
          theList = listCache[$(this).data("list-id")]
          $listContainer = $(theList.container)
          item = this
          iLikeToMoveItMoveIt = ->
            theList.dragStart.call item, evt
            $listContainer.off "mousemove", iLikeToMoveItMoveIt
            return
          $listContainer.mousemove(iLikeToMoveItMoveIt).mouseup ->
            $listContainer.off "mousemove", iLikeToMoveItMoveIt
            $dragHandle.css "cursor", $dragHandle.data("cursor")
            return
          return

        dragStart: (evt) ->
          theList.dropItem() if theList?.draggedItem?
          theList = listCache[$(this).data("list-id")]
          theList.draggedItem = $(evt.target).closest(listItemTag)
          
          #record current position so on dragend we know if the dragged item changed position or not
          theList.draggedItem.data "original-position", $(this).data("list-id") + "-" + theList.getItems().index(theList.draggedItem)
          
          #calculate mouse offset relative to draggedItem
          mt = parseInt(theList.draggedItem.css("marginTop"))
          ml = parseInt(theList.draggedItem.css("marginLeft"))
          theList.offset = theList.draggedItem.offset()
          theList.offset.top = evt.pageY - theList.offset.top + ((if isNaN(mt) then 0 else mt)) - 1
          theList.offset.left = evt.pageX - theList.offset.left + ((if isNaN(ml) then 0 else ml)) - 1
          
          $listContainer = $(theList.container)
          containerHeight = if $listContainer.outerHeight() is 0
            Math.max(1, Math.round(0.5 + theList.getItems().size() * theList.draggedItem.outerWidth() / $listContainer.outerWidth())) * theList.draggedItem.outerHeight()
          else
            $listContainer.outerHeight()
          theList.offsetLimit = $listContainer.offset()
          theList.offsetLimit.right = theList.offsetLimit.left + $listContainer.outerWidth() - theList.draggedItem.outerWidth()
          theList.offsetLimit.bottom = theList.offsetLimit.top + containerHeight - theList.draggedItem.outerHeight()
          
          #create placeholder item
          h = theList.draggedItem.height()
          w = theList.draggedItem.width()
          theList.draggedItem.after placeHolderTemplate
          theList.placeHolderItem = theList.draggedItem.next().css(
            height: h
            width: w
          ).data "is-placeholder", true
          
          originalStyle = theList.draggedItem.attr "style"
          theList.draggedItem.data "original-style", (if originalStyle then originalStyle else "")
          theList.draggedItem.css
            position: "absolute"
            opacity: 0.8
            "z-index": 999
            height: h
            width: w

          #auto-scroll setup
          theList.scroll =
            moveX: 0
            moveY: 0
            maxX: $(opts.document).width() - $(opts.window).width()
            maxY: $(opts.document).height() - $(opts.window).height()

          theList.scroll.scrollY = opts.window.setInterval(->
            t = $(opts.window).scrollTop()
            if theList.scroll.moveY > 0 and t < theList.scroll.maxY or theList.scroll.moveY < 0 and t > 0
              $(opts.window).scrollTop t + theList.scroll.moveY
              theList.draggedItem.css "top", theList.draggedItem.offset().top + theList.scroll.moveY + 1
            return
          , 10)
          theList.scroll.scrollX = opts.window.setInterval(->
            l = $(opts.window).scrollLeft()
            if theList.scroll.moveX > 0 and l < theList.scroll.maxX or theList.scroll.moveX < 0 and l > 0
              $(opts.window).scrollLeft l + theList.scroll.moveX
              theList.draggedItem.css "left", theList.draggedItem.offset().left + theList.scroll.moveX + 1
            return
          , 10)
          
          $(listCache).each (i, l) ->
            l.buildPositionTable()
            return

          theList.setPos evt.pageX, evt.pageY
          $(opts.document).on "mousemove", theList.swapItems
          $(opts.document).on "mouseup", theList.dropItem
          return

        
        #set position of draggedItem
        setPos: (x, y) ->
          top = Math.min(@offsetLimit.bottom, Math.max(y - @offset.top, @offsetLimit.top))
          left = Math.min(@offsetLimit.right, Math.max(x - @offset.left, @offsetLimit.left))
          
          #adjust top, left calculations to parent element instead of window if it's relative or absolute
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
          theList.scroll.moveX = (if x is 0 then 0 else x * 5 / Math.abs(x))
          theList.scroll.moveY = (if y is 0 then 0 else y * 5 / Math.abs(y))
          
          #move draggedItem to new mouse cursor location
          @draggedItem.css
            top: top
            left: left
          return

        #build a table recording all the positions of the moveable list items
        buildPositionTable: ->
          position = []
          @getItems().not([
            theList.draggedItem[0]
            theList.placeHolderItem[0]
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
          return  unless theList.draggedItem?
          
          originalStyle = theList.draggedItem.data "original-style"
          theList.draggedItem.attr "style", originalStyle
          theList.draggedItem.removeAttr "style"  if originalStyle is ""
          theList.draggedItem.removeData "original-style"
          theList.styleDragHandlers true
          theList.placeHolderItem.before theList.draggedItem
          theList.placeHolderItem.remove()
          $(":data(droptarget)").remove()
          opts.window.clearInterval theList.scroll.scrollY
          opts.window.clearInterval theList.scroll.scrollX
          
          #if position changed call callback
          opts.callback.apply theList.draggedItem  unless theList.draggedItem.data("original-position") is $(listCache).index(theList) + "-" + theList.getItems().index(theList.draggedItem)
          theList.draggedItem.removeData "original-position"
          theList.draggedItem = null
          $(opts.document).off "mousemove", theList.swapItems
          $(opts.document).off "mouseup", theList.dropItem
          false

        #swap the draggedItem (represented visually by placeholder) with the list item the it has been dragged on top of
        swapItems: (evt) ->
          return false unless theList.draggedItem?
          
          #move draggedItem to mouse location
          theList.setPos evt.pageX, evt.pageY
          
          #retrieve list and item position mouse cursor is over
          listIndex = theList.findPosition(evt.pageX, evt.pageY)
          aList = theList
          return false if listIndex is -1
          
          #save fixed items locations
          children = ->
            $(aList.container).children().not aList.draggedItem

          fixed = children().not(listItemTag).each ->
            @fixedIndex = children().index this
            return

          #if moving draggedItem up or left place placeHolder before list item the dragged item is hovering over otherwise place it after
          if not lastPosition? or lastPosition.top > theList.draggedItem.offset().top or lastPosition.left > theList.draggedItem.offset().left
            $(aList.position[listIndex].elm).before theList.placeHolderItem
          else
            $(aList.position[listIndex].elm).after theList.placeHolderItem
          
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

          lastPosition = theList.draggedItem.offset()
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
