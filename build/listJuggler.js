(function() {
  (function($, document, window) {
    var ALLOWED;
    ALLOWED = ["OL", "UL"];
    $.fn.listJuggler = function(options) {
      var lastPosition, listCache, opts, theList;
      if (options === "destroy") {
        $(this.selector).trigger("listJuggler-destroy");
        return;
      }
      opts = $.extend(true, {}, $.fn.listJuggler.defaults, options);
      listCache = [];
      theList = null;
      lastPosition = null;
      console.debug("this is", this);
      this.each(function(i, cont) {
        var listItemTag, listTemplate, placeHolderTemplate, tag;
        tag = $(this).prop("tagName");
        if (ALLOWED.indexOf(tag) === -1) {
          throw "You can only apply this plugin to ordered or unordered lists";
        }
        listItemTag = "li";
        placeHolderTemplate = "<" + listItemTag + ">&nbsp;</" + listItemTag + ">";
        console.debug("container", cont, "is in iframe's document", $.contains(opts.document, cont));
        listTemplate = {
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
            theList = listCache[$(this).data("list-id")];
            $(theList.container).off("mousedown", theList.grabItem).off("listJuggler-destroy");
            theList.styleDragHandlers(false);
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
            var $dragHandle, $listContainer, dragHandle, iLikeToMoveItMoveIt, item;
            if (evt.which !== 1 || $(evt.target).closest(listItemTag).size() === 0) {
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
            theList = listCache[$(this).data("list-id")];
            $listContainer = $(theList.container);
            item = this;
            iLikeToMoveItMoveIt = function() {
              theList.dragStart.call(item, evt);
              $listContainer.off("mousemove", iLikeToMoveItMoveIt);
            };
            $listContainer.mousemove(iLikeToMoveItMoveIt).mouseup(function() {
              $listContainer.off("mousemove", iLikeToMoveItMoveIt);
              $dragHandle.css("cursor", $dragHandle.data("cursor"));
            });
          },
          dragStart: function(evt) {
            var $listContainer, containerHeight, h, ml, mt, originalStyle, w;
            if ((theList != null ? theList.draggedItem : void 0) != null) {
              theList.dropItem();
            }
            theList = listCache[$(this).data("list-id")];
            theList.draggedItem = $(evt.target).closest(listItemTag);
            theList.draggedItem.data("original-position", $(this).data("list-id") + "-" + theList.getItems().index(theList.draggedItem));
            mt = parseInt(theList.draggedItem.css("marginTop"));
            ml = parseInt(theList.draggedItem.css("marginLeft"));
            theList.offset = theList.draggedItem.offset();
            theList.offset.top = evt.pageY - theList.offset.top + (isNaN(mt) ? 0 : mt) - 1;
            theList.offset.left = evt.pageX - theList.offset.left + (isNaN(ml) ? 0 : ml) - 1;
            $listContainer = $(theList.container);
            containerHeight = $listContainer.outerHeight() === 0 ? Math.max(1, Math.round(0.5 + theList.getItems().size() * theList.draggedItem.outerWidth() / $listContainer.outerWidth())) * theList.draggedItem.outerHeight() : $listContainer.outerHeight();
            theList.offsetLimit = $listContainer.offset();
            theList.offsetLimit.right = theList.offsetLimit.left + $listContainer.outerWidth() - theList.draggedItem.outerWidth();
            theList.offsetLimit.bottom = theList.offsetLimit.top + containerHeight - theList.draggedItem.outerHeight();
            h = theList.draggedItem.height();
            w = theList.draggedItem.width();
            theList.draggedItem.after(placeHolderTemplate);
            theList.placeHolderItem = theList.draggedItem.next().css({
              height: h,
              width: w
            }).data("is-placeholder", true);
            originalStyle = theList.draggedItem.attr("style");
            theList.draggedItem.data("original-style", (originalStyle ? originalStyle : ""));
            theList.draggedItem.css({
              position: "absolute",
              opacity: 0.8,
              "z-index": 999,
              height: h,
              width: w
            });
            theList.scroll = {
              moveX: 0,
              moveY: 0,
              maxX: $(opts.document).width() - $(opts.window).width(),
              maxY: $(opts.document).height() - $(opts.window).height()
            };
            theList.scroll.scrollY = opts.window.setInterval(function() {
              var t;
              t = $(opts.window).scrollTop();
              if (theList.scroll.moveY > 0 && t < theList.scroll.maxY || theList.scroll.moveY < 0 && t > 0) {
                $(opts.window).scrollTop(t + theList.scroll.moveY);
                theList.draggedItem.css("top", theList.draggedItem.offset().top + theList.scroll.moveY + 1);
              }
            }, 10);
            theList.scroll.scrollX = opts.window.setInterval(function() {
              var l;
              l = $(opts.window).scrollLeft();
              if (theList.scroll.moveX > 0 && l < theList.scroll.maxX || theList.scroll.moveX < 0 && l > 0) {
                $(opts.window).scrollLeft(l + theList.scroll.moveX);
                theList.draggedItem.css("left", theList.draggedItem.offset().left + theList.scroll.moveX + 1);
              }
            }, 10);
            $(listCache).each(function(i, l) {
              l.buildPositionTable();
            });
            theList.setPos(evt.pageX, evt.pageY);
            $(opts.document).on("mousemove", theList.swapItems);
            $(opts.document).on("mouseup", theList.dropItem);
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
            theList.scroll.moveX = (x === 0 ? 0 : x * 5 / Math.abs(x));
            theList.scroll.moveY = (y === 0 ? 0 : y * 5 / Math.abs(y));
            this.draggedItem.css({
              top: top,
              left: left
            });
          },
          buildPositionTable: function() {
            var position;
            position = [];
            this.getItems().not([theList.draggedItem[0], theList.placeHolderItem[0]]).each(function(i) {
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
            if (theList.draggedItem == null) {
              return;
            }
            originalStyle = theList.draggedItem.data("original-style");
            theList.draggedItem.attr("style", originalStyle);
            if (originalStyle === "") {
              theList.draggedItem.removeAttr("style");
            }
            theList.draggedItem.removeData("original-style");
            theList.styleDragHandlers(true);
            theList.placeHolderItem.before(theList.draggedItem);
            theList.placeHolderItem.remove();
            $(":data(droptarget)").remove();
            opts.window.clearInterval(theList.scroll.scrollY);
            opts.window.clearInterval(theList.scroll.scrollX);
            if (theList.draggedItem.data("original-position") !== $(listCache).index(theList) + "-" + theList.getItems().index(theList.draggedItem)) {
              opts.callback.apply(theList.draggedItem);
            }
            theList.draggedItem.removeData("original-position");
            theList.draggedItem = null;
            $(opts.document).off("mousemove", theList.swapItems);
            $(opts.document).off("mouseup", theList.dropItem);
            return false;
          },
          swapItems: function(evt) {
            var aList, children, fixed, listIndex;
            if (theList.draggedItem == null) {
              return false;
            }
            theList.setPos(evt.pageX, evt.pageY);
            listIndex = theList.findPosition(evt.pageX, evt.pageY);
            aList = theList;
            if (listIndex === -1) {
              return false;
            }
            children = function() {
              return $(aList.container).children().not(aList.draggedItem);
            };
            fixed = children().not(listItemTag).each(function() {
              this.fixedIndex = children().index(this);
            });
            if ((lastPosition == null) || lastPosition.top > theList.draggedItem.offset().top || lastPosition.left > theList.draggedItem.offset().left) {
              $(aList.position[listIndex].elm).before(theList.placeHolderItem);
            } else {
              $(aList.position[listIndex].elm).after(theList.placeHolderItem);
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
            lastPosition = theList.draggedItem.offset();
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
      callback: function() {},
      document: document,
      window: window
    };
  })(jQuery, self.document, self);

}).call(this);
