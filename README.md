listJuggler Examples
====================

Usage examples of the [ListJuggler](https://github.com/davesag/listJuggler) jQuery plugin
that allows manual sorting of list elements via drop and drag.
Designed to work within an iFrame if necessary.

## To use

```html
<ol>
  <li>One</li>
  <li>Two</li>
  <li>Three</li>
</ol>
```

```javascript
$(document).ready(function(){
  $("ol").listJuggler();
});
```

### Options

`callback`: a callback that is fired when the list item drops.

```javascript
$(document).ready(function(){
  $("ol").listJuggler({
    callback: function(item, container){
      console.log("yay - an item dropped", item, "within", container);
    }
  });
});
```

You can also override the default `document` and `window` instances in cases
where you are running this script against lists that are contained
in an iFrame but the script itself is running in the parent window.
This happens when you are writing **browser extensions** for example.

```javascript
$(document).ready(function(){
  $("ol").listJuggler({
    document: $("iframe").get(0).contentDocument
    window: $("iframe").get(0).contentWindow
  });
});
```

## Thanks

Thanks to the gang at [Maxwell Forest](http://www.maxwellforest.com) for giving me
the time to do this properly. Thanks to [jfriend00](http://stackoverflow.com/users/816620/jfriend00) over at StackOverflow for his patience and help getting
my iFrame stuff to work. And thanks to whoever wrote [Dragsort](http://dragsort.codeplex.com) for providing the inspiration for this.

## History

I started out with a very simple need - namely I had to allow the users of the
Chrome Extension I'm writing for [Maxwell Forest](http://www.maxwellforest.com)
to manually sort elements in a list.

I first looked at using [jQueryUI](http://jqueryui.com/sortable/) but decided there had to be a much lighter-weight way to achieve this.

Then I found [Dragsort](http://dragsort.codeplex.com) which was cool but hadn't been updated in a couple of years and which also didn't work when called on elements within iFrames, something I specifically needed. And I didn't need all the other
fancy stuff that Dragsort does.

So I decided to roll my own, using Dragsort as a template, but rewriting it pretty much completely from the ground up and in Coffeescript, and with unit tests.
