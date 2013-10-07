// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty;

  Backbone.tinywings = (function(Backbone, _) {
    var BOOLEAN_ATTRIBUTES, Tinywings, buildInBind, debug, log, preprocessBind, traversal;
    debug = true;
    log = function() {
      if (debug) {
        return console.log.apply(console, arguments);
      }
    };
    BOOLEAN_ATTRIBUTES = ['disabled', 'readonly'];
    traversal = function(node, process) {
      /*
      Stop in new tinywings context
      */

      var done, next, stop;
      stop = false;
      done = function() {
        return stop = true;
      };
      node = node.firstChild;
      while (node) {
        log("travel " + node);
        next = node.nextSibling;
        process(node, done);
        if (!stop) {
          traversal(node, process);
        }
        node = next;
      }
    };
    preprocessBind = function(node) {
      var attr, bind, type, _ref;
      if ((_ref = node.dataset) != null ? _ref.bind : void 0) {
        bind = node.dataset.bind;
        bind = bind.split(':');
        type = bind.shift();
        attr = bind.join(':');
      }
      return [type, attr];
    };
    buildInBind = {
      text: function(node, attr) {
        log("text-bind to " + node + " with " + attr);
        return this._bind(attr, function(val) {
          node.innerHTML = val + '';
          return log("text-refrash to " + node + " with " + val);
        });
      },
      attr: function(node, attr) {
        var key, value, _results,
          _this = this;
        log("attr-bind to " + node + " with " + attr);
        attr = JSON.parse(attr);
        _results = [];
        for (key in attr) {
          value = attr[key];
          if (BOOLEAN_ATTRIBUTES.indexOf(key) > -1) {
            _results.push((function(key, value) {
              return _this._bind(value, function(val) {
                if (BOOLEAN_ATTRIBUTES.indexOf(key) > -1) {
                  node[key] = !!val;
                } else {
                  node[key] = val;
                }
                return log("attr-refrash to " + node + " with " + val);
              });
            })(key, value));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      },
      value: function(node, attr) {
        log("value-bind to " + node + " with " + attr);
        return this._bind(attr, function(val) {
          node.value = val;
          return log("value-refrash to " + node + " with " + val);
        });
      },
      "if": function(node, attr, done) {
        var innerTpl;
        done();
        innerTpl = node.innerHTML;
        log("ifnot-bind to " + node + " with " + attr);
        return this._bind(attr, function(val, valObj) {
          var child, innerDomTpl, key, next, value;
          node.innerHTML = '';
          log("ifnot-refrash to " + node + " with " + val);
          if (!val) {
            return;
          }
          innerDomTpl = new Tinywings(innerTpl);
          /*
          Copy children elements
          */

          child = innerDomTpl.frag.firstChild;
          while (child) {
            next = child.nextSibling;
            node.appendChild(child);
            child = next;
          }
          for (key in innerDomTpl) {
            if (!__hasProp.call(innerDomTpl, key)) continue;
            value = innerDomTpl[key];
            if (key !== 'frag') {
              if (valObj[key] != null) {
                innerDomTpl[key](valObj[key], valObj, node);
              }
            }
          }
        });
      },
      "with": function(node, attr, done) {
        var innerTpl;
        done();
        innerTpl = node.innerHTML;
        log("with-bind to " + node + " with " + attr);
        return this._bind(attr, function(val) {
          var child, innerDomTpl, key, next, value;
          node.innerHTML = '';
          log("with-refrash to " + node + " with " + val);
          innerDomTpl = new Tinywings(innerTpl);
          child = innerDomTpl.frag.firstChild;
          while (child) {
            next = child.nextSibling;
            node.appendChild(child);
            child = next;
          }
          for (key in innerDomTpl) {
            if (!__hasProp.call(innerDomTpl, key)) continue;
            value = innerDomTpl[key];
            if (['frag', 'updaters'].indexOf(key) === -1) {
              if (val[key] != null) {
                innerDomTpl[key](val[key], val, node);
              }
            }
          }
        });
      },
      ifnot: function(node, attr, done) {
        var innerTpl;
        done();
        innerTpl = node.innerHTML;
        log("if-bind to " + node + " with " + attr);
        return this._bind(attr, function(val, valObj) {
          var child, innerDomTpl, key, next, value;
          node.innerHTML = '';
          log("if-refrash to " + node + " with " + val);
          if (!!val) {
            return;
          }
          innerDomTpl = new Tinywings(innerTpl);
          /*
          Copy children elements
          */

          child = innerDomTpl.frag.firstChild;
          while (child) {
            next = child.nextSibling;
            node.appendChild(child);
            child = next;
          }
          for (key in innerDomTpl) {
            if (!__hasProp.call(innerDomTpl, key)) continue;
            value = innerDomTpl[key];
            if (key !== 'frag') {
              if (valObj[key] != null) {
                innerDomTpl[key](valObj[key], valObj, node);
              }
            }
          }
        });
      },
      foreach: function(node, attr, done) {
        var innerTpl;
        done();
        innerTpl = node.innerHTML;
        log("foreach-bind to " + node + " with " + attr);
        return this._bind(attr, function(val) {
          var child, innerDomTpl, item, key, next, value, _i, _len;
          node.innerHTML = '';
          log("foreach-refrash to " + node + " with " + val);
          for (_i = 0, _len = val.length; _i < _len; _i++) {
            item = val[_i];
            innerDomTpl = new Tinywings(innerTpl);
            /*
            Copy children elements
            */

            child = innerDomTpl.frag.firstChild;
            while (child) {
              next = child.nextSibling;
              node.appendChild(child);
              child = next;
            }
            for (key in innerDomTpl) {
              if (!__hasProp.call(innerDomTpl, key)) continue;
              value = innerDomTpl[key];
              if (['frag', 'updaters'].indexOf(key) === -1) {
                if (item[key]) {
                  innerDomTpl[key](item[key], item, node);
                }
              }
            }
          }
        });
      }
    };
    Tinywings = function(tpl) {
      this.updaters = {};
      this.frag = document.createElement('div');
      this.frag.innerHTML = tpl;
      return this.preprocess();
    };
    _.extend(Tinywings.prototype, Backbone.Events, {
      preprocess: function() {
        var _this = this;
        traversal(this.frag, function(node, done) {
          var attr, type, _ref;
          if (node.nodeType === 3) {
            return _this.bindTextNode(node);
          }
          _ref = preprocessBind(node), type = _ref[0], attr = _ref[1];
          if ((type != null) && (attr != null)) {
            _this.bind(node, type, attr, done);
          }
        });
      },
      bind: function(node, type, attr, done) {
        return buildInBind[type].apply(this, [node, attr, done]);
      },
      _bind: function(attr, updater) {
        var attrLink, first, _base;
        first = attr.split('.')[0];
        (_base = this.updaters)[first] || (_base[first] = []);
        this[first] || (this[first] = function(val, valObj, parent) {
          var up, _i, _len, _ref;
          _ref = this.updaters[first];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            up = _ref[_i];
            up(val, valObj, parent);
          }
        });
        if (attr.indexOf('.') > -1) {
          attrLink = attr.split('.');
          first = attrLink.shift();
          this.updaters[first].push(function(val, valObj, parent) {
            var atr, _i, _len;
            for (_i = 0, _len = attrLink.length; _i < _len; _i++) {
              atr = attrLink[_i];
              val = val[atr];
            }
            updater(val, valObj, parent);
          });
        } else {
          this.updaters[first].push(updater);
        }
      },
      bindTextNode: function(node) {
        var attr, bind, child, first, last, match, matches, newData, newNode, next, parent, tempObj, _fn, _i, _j, _len, _len1, _ref,
          _this = this;
        if (!/{{[^}]*}}/.test(node.data)) {
          return;
        }
        log("text-bind to " + node);
        matches = node.data.match(/{{[^}]*}}/g);
        tempObj = {};
        for (_i = 0, _len = matches.length; _i < _len; _i++) {
          match = matches[_i];
          tempObj[match] = match;
        }
        matches = Object.keys(tempObj);
        newData = node.data;
        parent = node.parentNode;
        _fn = function(attr, parent) {
          return _this._bind(attr, function(val, valObj, p) {
            var nodes, _k, _len2;
            p || (p = parent);
            nodes = p.childNodes;
            for (_k = 0, _len2 = nodes.length; _k < _len2; _k++) {
              node = nodes[_k];
              if ((node.data != null) && node.data.indexOf("data-bind='_text:" + attr + "'") > -1) {
                node.nextSibling.data = val;
                log("text-refrash to " + node + " with " + val);
              }
            }
          });
        };
        for (_j = 0, _len1 = matches.length; _j < _len1; _j++) {
          match = matches[_j];
          _ref = /{{([^}]*)}}/.exec(match), bind = _ref[0], attr = _ref[1];
          newData = newData.replace(new RegExp(bind, 'g'), "<!-- data-bind='_text:" + attr + "' -->" + bind + "<!-- -->");
          _fn(attr, parent);
        }
        newNode = document.createElement('div');
        newNode.innerHTML = newData;
        /*
        Replce origin text node
        */

        first = child = newNode.firstChild;
        while (child) {
          next = child.nextSibling;
          if (child === first) {
            parent.replaceChild(child, node);
          } else {
            if (parent.lastChild === last) {
              parent.appendChild(child);
            } else {
              parent.insertBefore(child, last.nextSibling);
            }
          }
          last = child;
          child = next;
        }
      },
      appendTo: function(el) {
        var child, next;
        child = this.frag.firstChild;
        while (child) {
          next = child.nextSibling;
          el.appendChild(child);
          child = next;
        }
        return this;
      },
      bindModel: function(model) {
        var attr, data,
          _this = this;
        data = model.toJSON();
        this.render(data);
        for (attr in data) {
          if (!__hasProp.call(data, attr)) continue;
          if (attr in this) {
            (function(attr) {
              return _this.listenTo(model, "change:" + attr, function() {
                data = model.toJSON();
                return _this[attr](data[attr], data);
              });
            })(attr);
          }
        }
        return this;
      },
      unbindModel: function(model) {
        return this.stopListening(model);
      },
      render: function(model) {
        var key, value;
        for (key in this) {
          if (!__hasProp.call(this, key)) continue;
          value = this[key];
          if (['frag', 'updaters'].indexOf(key) === -1) {
            this[key](model[key], model);
          }
        }
        return this;
      }
    });
    return function(tpl) {
      return new Tinywings(tpl);
    };
  })(Backbone, _);

}).call(this);
