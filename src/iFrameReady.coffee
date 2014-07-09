# adapted from an answer by @jfriend00 in
# http://stackoverflow.com/questions/24603580/how-can-i-access-the-dom-elements-within-an-iframe
window.iFrameReady = (iFrame, fn) ->
  timer = undefined
  fired = false

  ready = ->
    unless fired
      fired = true
      clearTimeout timer
      fn.call this
    return
  readyState = ->
    ready.call this if @readyState is "complete"
    return
  
  # cross platform event handler for compatibility with older IE versions
  addEvent = (elem, event, fn) ->
    if elem.addEventListener
      elem.addEventListener event, fn
    else
      elem.attachEvent "on" + event, ->
        fn.call elem, window.event

  # use iFrame load as a backup - though the other events should occur first
  checkLoaded = ->
    doc = iFrame.contentDocument or iFrame.contentWindow.document
    
    # We can tell if there is a dummy document installed because the dummy document
    # will have an URL that starts with "about:".  The real document will not have that URL
    if doc.URL.indexOf("about:") isnt 0
      if doc.readyState is "complete"
        ready.call doc
      else
        
        # set event listener for DOMContentLoaded on the new document
        addEvent doc, "DOMContentLoaded", ready
        addEvent doc, "readystatechange", readyState
    else
      
      # still same old original document, so keep looking for content or new document
      timer = setTimeout(checkLoaded, 1)
    return

  addEvent iFrame, "load", ->
    ready.call iFrame.contentDocument or iFrame.contentWindow.document
    return

  checkLoaded()
  return
