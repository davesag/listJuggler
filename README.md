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

There is only one option which is a callback that is fired when
the list item drops.

```javascript
$(document).ready(function(){
  $("ol").listJuggler({
    callback: function(item){
      console.log("yay - an item dropped", item);
    }
  });
});
```

## To Build

### First

Assuming you have `Node.js` and `Grunt` installed.

```bash
npm install
```

## To Test

```bash
grunt test
```

### To Build

```bash
grunt
```

This will output the final distribution files into the `dist/` folder, prefixed with `jquery` and suffixed with the version number you specify in `package.json`.

Files created are:

* `jquery-listJuggler.1.0.0.js` - the 'developer' version.
* `jquery-listJuggler.1.0.0.min.js` The minified version for production use.
* `jquery-listJuggler.1.0.0.min.map` The `sourcemap` file for debugging using the minified version.

