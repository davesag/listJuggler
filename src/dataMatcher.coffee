(($)->
  resolve = (element, dataName) ->
    dataArray =             dataName.match(/(?:\\\.|[^.])+(?=\.|$)/g)
    cur = $(element).data dataArray.shift()
    cur = cur[dataArray.shift()] while cur and dataArray[0]
    return cur or undefined
  
  matcher = /\s*(?:((?:(?:\\\.|[^.,])+\.?)+)\s*([!~><=]=|[><])\s*("|')?((?:\\\3|.)*?)\3|(.+?))\s*(?:,|$)/g
  
  $.expr[":"].data = (el, i, match) ->
    matcher.lastIndex = 0
    expr = match[3]
    m = undefined
    check = undefined
    val = undefined
    allMatch = null
    foundMatch = false
    while m = matcher.exec(expr)
      check = m[4]
      val = resolve(el, m[1] or m[5])
      switch m[2]
        when "=="
          foundMatch = val is check
        when "!="
          foundMatch = val isnt check
        when "<="
          foundMatch = val <= check
        when ">="
          foundMatch = val >= check
        when "~="
          foundMatch = (new RegExp(check)).test(val)
        when ">"
          foundMatch = val > check
        when "<"
          foundMatch = val < check
        else
          foundMatch = !!val  if m[5]
      allMatch = (if allMatch is null then foundMatch else allMatch and foundMatch)
    return allMatch

  return
) jQuery
