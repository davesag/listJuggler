(function() {
  (function($) {
    var matcher, resolve;
    resolve = function(element, dataName) {
      var cur, dataArray;
      dataArray = dataName.match(/(?:\\\.|[^.])+(?=\.|$)/g);
      cur = $(element).data(dataArray.shift());
      while (cur && dataArray[0]) {
        cur = cur[dataArray.shift()];
      }
      return cur || void 0;
    };
    matcher = /\s*(?:((?:(?:\\\.|[^.,])+\.?)+)\s*([!~><=]=|[><])\s*("|')?((?:\\\3|.)*?)\3|(.+?))\s*(?:,|$)/g;
    $.expr[":"].data = function(el, i, match) {
      var allMatch, check, expr, foundMatch, m, val;
      matcher.lastIndex = 0;
      expr = match[3];
      m = void 0;
      check = void 0;
      val = void 0;
      allMatch = null;
      foundMatch = false;
      while (m = matcher.exec(expr)) {
        check = m[4];
        val = resolve(el, m[1] || m[5]);
        switch (m[2]) {
          case "==":
            foundMatch = val === check;
            break;
          case "!=":
            foundMatch = val !== check;
            break;
          case "<=":
            foundMatch = val <= check;
            break;
          case ">=":
            foundMatch = val >= check;
            break;
          case "~=":
            foundMatch = (new RegExp(check)).test(val);
            break;
          case ">":
            foundMatch = val > check;
            break;
          case "<":
            foundMatch = val < check;
            break;
          default:
            if (m[5]) {
              foundMatch = !!val;
            }
        }
        allMatch = (allMatch === null ? foundMatch : allMatch && foundMatch);
      }
      return allMatch;
    };
  })(jQuery);

}).call(this);
