(function() {
  window.iFrameReady = function(iFrame, fn) {
    var addEvent, checkLoaded, fired, ready, readyState, timer;
    timer = void 0;
    fired = false;
    ready = function() {
      if (!fired) {
        fired = true;
        clearTimeout(timer);
        fn.call(this);
      }
    };
    readyState = function() {
      if (this.readyState === "complete") {
        ready.call(this);
      }
    };
    addEvent = function(elem, event, fn) {
      if (elem.addEventListener) {
        return elem.addEventListener(event, fn);
      } else {
        return elem.attachEvent("on" + event, function() {
          return fn.call(elem, window.event);
        });
      }
    };
    checkLoaded = function() {
      var doc;
      doc = iFrame.contentDocument || iFrame.contentWindow.document;
      if (doc.URL.indexOf("about:") !== 0) {
        if (doc.readyState === "complete") {
          ready.call(doc);
        } else {
          addEvent(doc, "DOMContentLoaded", ready);
          addEvent(doc, "readystatechange", readyState);
        }
      } else {
        timer = setTimeout(checkLoaded, 1);
      }
    };
    addEvent(iFrame, "load", function() {
      ready.call(iFrame.contentDocument || iFrame.contentWindow.document);
    });
    checkLoaded();
  };

}).call(this);
