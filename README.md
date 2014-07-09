listJuggler
===========

A jQuery Plugin for manually sorting list elements via drop and drag.
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
    callback: function(item){
      console.log("yay - an item dropped", item);
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

### Examples

See the examples in the `example/` folder

To properly get the iFrameExternallyReferencedExample to work you need to
run the examples within a local web server.  To do this simply run

    node webServer

Then point your browser to http://locahost:8080

This of course assumes you have `Node.js` installed.
See the build instructions below for more on that.

## To Build

### First

Assuming you have `Node.js` and `Grunt` installed.

```bash
npm install
```

### Test

```bash
grunt test
```

### Build

```bash
grunt
```

This will output the final distribution files into the `dist/` folder, prefixed with `jquery` and suffixed with the version number you specify in `package.json`.

Files created are:

* `jquery-listJuggler.1.0.1.js` - the 'developer' version.
* `jquery-listJuggler.1.0.1.min.js` The minified version for production use.
* `jquery-listJuggler.1.0.1.min.map` The `sourcemap` file for debugging using the minified version.

## Thanks

Thanks to the gang at [Maxwell Forest](http://www.maxwellforest.com) for giving me
the time to do this properly. Thanks to [jfriend00](http://stackoverflow.com/users/816620/jfriend00) over at StackOverflow for his patience and help getting
my iFrame stuff to work. And thanks to whoever wrote [Dragsort](http://dragsort.codeplex.com) for providing the inspiration for this.

## History

I started out with a very simple need - namely I had to allow the users of the
Chrome Extension I'm writing for [Maxwell Forest](http://www.maxwellforest.com)
to manually sort elements in a list.

I first looked at using [jQueryUI](http://jqueryui.com/sortable/) but decided there had to be a much lighter-weight way to achieve this.

Then I found [Dragsort](http://dragsort.codeplex.com) which was cool but hadn't been updated in a couple of years and which also didn't work when called on elelemnts within iFrames, something I specifically needed.

So I decided to roll my own, using Dragsort as a template, but rewriting it pretty much completely from the ground up and in Coffeescript, and with unit tests.
