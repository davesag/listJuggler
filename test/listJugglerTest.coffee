(($) ->
  ###
    ======== A Handy Little QUnit Reference ========
    http://api.qunitjs.com/

    Test methods:
      module(name, {[setup][ ,teardown]})
      test(name, callback)
      expect(numberOfAssertions)
      stop(increment)
      start(decrement)
    Test assertions:
      ok(value, [message])
      equal(actual, expected, [message])
      notEqual(actual, expected, [message])
      deepEqual(actual, expected, [message])
      notDeepEqual(actual, expected, [message])
      strictEqual(actual, expected, [message])
      notStrictEqual(actual, expected, [message])
      throws(block, [expected], [message])
  ###

  module "basic tests",
  
    setup: ->
      this.elems = $("#qunit-fixture").children(".qunit-container")

  # all jQuery plugins must be chainable.
  test "doesn't work if not an ordered or unordered list", ->
    throws ->
      this.elems.listJuggler()
    , "Expected an error if applied to anything other than an ordered or unordered list"

  test "works with ordered lists", ->
    ordered = this.elems.find "ol"
    strictEqual(ordered.listJuggler(), ordered, "ordered list should be chainable")

  test "works with unordered lists", ->
    unordered = this.elems.find "ul"
    strictEqual(unordered.listJuggler(), unordered, "unordered list should be chainable")

) jQuery
