(function() {
  (function($, document, window) {
    var ALLOWED;
    ALLOWED = ["OL", "UL"];
    $.fn.listJuggler = function(options) {
      var lastPosition, listCache, opts, theItem;
      if (options === "destroy") {
        $(this.selector).trigger("listJuggler-destroy");
        return;
      }
      opts = $.extend(true, {}, $.fn.listJuggler.defaults, options);
      listCache = [];
      theItem = null;
      lastPosition = null;
      this.each(function(i, cont) {
        var listItemTag, listTemplate, placeHolderTemplate, tag;
        tag = $(this).prop("tagName");
        if (ALLOWED.indexOf(tag) === -1) {
          throw "You can only apply this plugin to ordered or unordered lists";
        }
        listItemTag = "li";
        placeHolderTemplate = "<" + listItemTag + ">&nbsp;</" + listItemTag + ">";
        listTemplate = {
          text: "",
          draggedItem: null,
          placeHolderItem: null,
          position: null,
          offset: null,
          offsetLimit: null,
          scroll: null,
          container: cont,
          init: function() {
            $(this.container).data("list-id", i).mousedown(this.grabItem).on("listJuggler-destroy", this.uninit);
            this.styleDragHandlers(true);
          },
          uninit: function() {
            theItem = listCache[$(this).data("list-id")];
            $(theItem.container).off("mousedown", theItem.grabItem).off("listJuggler-destroy");
            theItem.styleDragHandlers(false);
          },
          getItems: function() {
            return $(this.container).children(listItemTag);
          },
          styleDragHandlers: function(cursor) {
            this.getItems().map(function() {
              if ($(this).is(listItemTag)) {
                return this;
              } else {
                return $(this).find(listItemTag).get();
              }
            }).css("cursor", (cursor ? "pointer" : ""));
          },
          grabItem: function(evt) {
            var $dragHandle, $listItemContainer, dragHandle, iLikeToMoveItMoveIt, item;
            if (evt.which !== 1 || $(evt.target).closest("" + listItemTag).size() === 0 || $(evt.target).closest(opts.clickableSelectors.join(",")).size() !== 0) {
              return;
            }
            evt.preventDefault();
            dragHandle = evt.target;
            while (!$(dragHandle).is(listItemTag)) {
              if (dragHandle === this) {
                return;
              }
              dragHandle = dragHandle.parentNode;
            }
            $dragHandle = $(dragHandle);
            $dragHandle.data("cursor", $dragHandle.css("cursor"));
            $dragHandle.css("cursor", "move");
            theItem = listCache[$(this).data("list-id")];
            $listItemContainer = $(theItem.container);
            item = this;
            iLikeToMoveItMoveIt = function() {
              theItem.dragStart.call(item, evt);
              $listItemContainer.off("mousemove", iLikeToMoveItMoveIt);
            };
            $listItemContainer.mousemove(iLikeToMoveItMoveIt).mouseup(function() {
              $listItemContainer.off("mousemove", iLikeToMoveItMoveIt);
              $dragHandle.css("cursor", $dragHandle.data("cursor"));
            });
          },
          dragStart: function(evt) {
            var $listItemContainer, containerHeight, h, ml, mt, originalStyle, w;
            if ((theItem != null ? theItem.draggedItem : void 0) != null) {
              theItem.dropItem();
            }
            theItem = listCache[$(this).data("list-id")];
            theItem.draggedItem = $(evt.target).closest(listItemTag);
            theItem.draggedItem.data("original-position", $(this).data("list-id") + "-" + theItem.getItems().index(theItem.draggedItem));
            mt = parseInt(theItem.draggedItem.css("marginTop"));
            ml = parseInt(theItem.draggedItem.css("marginLeft"));
            theItem.offset = theItem.draggedItem.offset();
            theItem.offset.top = evt.pageY - theItem.offset.top + (isNaN(mt) ? 0 : mt) - 1;
            theItem.offset.left = evt.pageX - theItem.offset.left + (isNaN(ml) ? 0 : ml) - 1;
            $listItemContainer = $(theItem.container);
            containerHeight = $listItemContainer.outerHeight() === 0 ? Math.max(1, Math.round(0.5 + theItem.getItems().size() * theItem.draggedItem.outerWidth() / $listItemContainer.outerWidth())) * theItem.draggedItem.outerHeight() : $listItemContainer.outerHeight();
            theItem.offsetLimit = $listItemContainer.offset();
            theItem.offsetLimit.right = theItem.offsetLimit.left + $listItemContainer.outerWidth() - theItem.draggedItem.outerWidth();
            theItem.offsetLimit.bottom = theItem.offsetLimit.top + containerHeight - theItem.draggedItem.outerHeight();
            h = theItem.draggedItem.height();
            w = theItem.draggedItem.width();
            theItem.draggedItem.after(placeHolderTemplate);
            theItem.placeHolderItem = theItem.draggedItem.next().css({
              height: h,
              width: w
            }).data("is-placeholder", true);
            originalStyle = theItem.draggedItem.attr("style");
            theItem.draggedItem.data("original-style", (originalStyle ? originalStyle : ""));
            theItem.draggedItem.css({
              position: "absolute",
              opacity: 0.8,
              "z-index": 999,
              height: h,
              width: w
            });
            theItem.scroll = {
              moveX: 0,
              moveY: 0,
              maxX: $(opts.document).width() - $(opts.window).width(),
              maxY: $(opts.document).height() - $(opts.window).height()
            };
            theItem.scroll.scrollY = opts.window.setInterval(function() {
              var t;
              t = $(opts.window).scrollTop();
              if (theItem.scroll.moveY > 0 && t < theItem.scroll.maxY || theItem.scroll.moveY < 0 && t > 0) {
                $(opts.window).scrollTop(t + theItem.scroll.moveY);
                theItem.draggedItem.css("top", theItem.draggedItem.offset().top + theItem.scroll.moveY + 1);
              }
            }, 10);
            theItem.scroll.scrollX = opts.window.setInterval(function() {
              var l;
              l = $(opts.window).scrollLeft();
              if (theItem.scroll.moveX > 0 && l < theItem.scroll.maxX || theItem.scroll.moveX < 0 && l > 0) {
                $(opts.window).scrollLeft(l + theItem.scroll.moveX);
                theItem.draggedItem.css("left", theItem.draggedItem.offset().left + theItem.scroll.moveX + 1);
              }
            }, 10);
            $(listCache).each(function(i, l) {
              l.buildPositionTable();
            });
            theItem.setPos(evt.pageX, evt.pageY);
            $(opts.document).on("mousemove", theItem.swapItems);
            $(opts.document).on("mouseup", theItem.dropItem);
          },
          setPos: function(x, y) {
            var left, top;
            top = Math.min(this.offsetLimit.bottom, Math.max(y - this.offset.top, this.offsetLimit.top));
            left = Math.min(this.offsetLimit.right, Math.max(x - this.offset.left, this.offsetLimit.left));
            this.draggedItem.parents().each(function() {
              var offset;
              if ($(this).css("position") !== "static" && $(this).css("display") !== "table") {
                offset = $(this).offset();
                top -= offset.top;
                left -= offset.left;
                return false;
              }
            });
            y -= $(opts.window).scrollTop();
            x -= $(opts.window).scrollLeft();
            y = Math.max(0, y - $(opts.window).height() + 5) + Math.min(0, y - 5);
            x = Math.max(0, x - $(opts.window).width() + 5) + Math.min(0, x - 5);
            theItem.scroll.moveX = (x === 0 ? 0 : x * 5 / Math.abs(x));
            theItem.scroll.moveY = (y === 0 ? 0 : y * 5 / Math.abs(y));
            this.draggedItem.css({
              top: top,
              left: left
            });
          },
          buildPositionTable: function() {
            var position;
            position = [];
            this.getItems().not([theItem.draggedItem[0], theItem.placeHolderItem[0]]).each(function(i) {
              var $this, loc;
              $this = $(this);
              loc = $this.offset();
              loc.right = loc.left + $this.outerWidth();
              loc.bottom = loc.top + $this.outerHeight();
              loc.elm = this;
              position[i] = loc;
            });
            this.position = position;
          },
          dropItem: function() {
            var originalStyle;
            if (theItem.draggedItem == null) {
              return;
            }
            originalStyle = theItem.draggedItem.data("original-style");
            theItem.draggedItem.attr("style", originalStyle);
            if (originalStyle === "") {
              theItem.draggedItem.removeAttr("style");
            }
            theItem.draggedItem.removeData("original-style");
            theItem.styleDragHandlers(true);
            theItem.placeHolderItem.before(theItem.draggedItem);
            theItem.placeHolderItem.remove();
            $(":data(droptarget)").remove();
            opts.window.clearInterval(theItem.scroll.scrollY);
            opts.window.clearInterval(theItem.scroll.scrollX);
            if (theItem.draggedItem.data("original-position") !== $(listCache).index(theItem) + "-" + theItem.getItems().index(theItem.draggedItem)) {
              opts.callback(theItem.draggedItem, $(theItem.container));
            }
            theItem.draggedItem.removeData("original-position");
            theItem.draggedItem = null;
            $(opts.document).off("mousemove", theItem.swapItems);
            $(opts.document).off("mouseup", theItem.dropItem);
            return false;
          },
          swapItems: function(evt) {
            var aList, children, fixed, listIndex;
            if (theItem.draggedItem == null) {
              return false;
            }
            theItem.setPos(evt.pageX, evt.pageY);
            listIndex = theItem.findPosition(evt.pageX, evt.pageY);
            aList = theItem;
            if (listIndex === -1) {
              return false;
            }
            children = function() {
              return $(aList.container).children().not(aList.draggedItem);
            };
            fixed = children().not(listItemTag).each(function() {
              this.fixedIndex = children().index(this);
            });
            if ((lastPosition == null) || lastPosition.top > theItem.draggedItem.offset().top || lastPosition.left > theItem.draggedItem.offset().left) {
              $(aList.position[listIndex].elm).before(theItem.placeHolderItem);
            } else {
              $(aList.position[listIndex].elm).after(theItem.placeHolderItem);
            }
            fixed.each(function() {
              var elm;
              elm = children().eq(this.fixedIndex).get(0);
              if (this !== elm && children().index(this) < this.fixedIndex) {
                $(this).insertAfter(elm);
              } else {
                if (this !== elm) {
                  $(this).insertBefore(elm);
                }
              }
            });
            $(listCache).each(function(i, l) {
              l.buildPositionTable();
            });
            lastPosition = theItem.draggedItem.offset();
            return false;
          },
          findPosition: function(x, y) {
            i = 0;
            while (i < this.position.length) {
              if (this.position[i].left < x && this.position[i].right > x && this.position[i].top < y && this.position[i].bottom > y) {
                return i;
              }
              i = i + 1;
            }
            return -1;
          }
        };
        listTemplate.init();
        listCache.push(listTemplate);
      });
      return this;
    };
    $.fn.listJuggler.defaults = {
      clickableSelectors: ["BUTTON", "A", "INPUT", "SELECT"],
      callback: function() {},
      document: document,
      window: window
    };
  })(jQuery, self.document, self);

}).call(this);
