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

See the example in the `example/` folder

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

