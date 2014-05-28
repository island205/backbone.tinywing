Backbone.tinywings = do (Backbone, _)->

  debug = true
  log = ->
    if debug
      console.log.apply console, arguments

  BOOLEAN_ATTRIBUTES = ['disabled', 'readonly']

  traversal = (node, process)->
    ###
    Stop in new tinywings context
    ###
    stop = false
    done = ->
      stop = true
    
    node = node.firstChild
    while node
      next = node.nextSibling
      process node, done
      if not stop
        traversal node, process
      node = next
    return

  preprocessBind = (node)->
    if node.dataset?.bind
      bind = node.dataset.bind
      bind = bind.split ':'
      type = bind.shift()
      attr = bind.join ':'
    [type, attr]

  buildInBind =
    text: (node, attr)->
      log "text-bind to #{node} with #{attr}"
      @_bind attr, (val)->
        node.innerHTML = val + ''
        log "text-refrash to #{node} with #{val}"

    attr: (node, attr)->
      log "attr-bind to #{node} with #{attr}"
      attr = JSON.parse attr
      for key, value of attr
        if BOOLEAN_ATTRIBUTES.indexOf(key) > -1
          do (key, value)=>
            @_bind value, (val)->
              if BOOLEAN_ATTRIBUTES.indexOf(key) > -1
                node[key] = not not val
              else
                node[key] = val
              log "attr-refrash to #{node} with #{val}"

    value: (node, attr)->
      log "value-bind to #{node} with #{attr}"
      @_bind attr, (val)->
        node.value = val
        log "value-refrash to #{node} with #{val}"

    if: (node, attr, done)->
      done()
      innerTpl = node.innerHTML
      log "ifnot-bind to #{node} with #{attr}"
      @_bind attr, (val, valObj)->
        node.innerHTML = ''
        log "ifnot-refrash to #{node} with #{val}"
        if not val
          return

        innerDomTpl = new Tinywings(innerTpl)

        ###
        Copy children elements
        ###
        child = innerDomTpl.frag.firstChild
        while child
          next = child.nextSibling
          node.appendChild child
          child = next

        for own key, value of innerDomTpl
          if key isnt 'frag'
            if valObj[key]?
              innerDomTpl[key] valObj[key], valObj, node
        return

    with: (node, attr, done)->
      done()
      innerTpl = node.innerHTML
      log "with-bind to #{node} with #{attr}"
      @_bind attr, (val)->
        node.innerHTML = ''
        log "with-refrash to #{node} with #{val}"
        innerDomTpl = new Tinywings(innerTpl)

        # copy children elements
        child = innerDomTpl.frag.firstChild
        while child
          next = child.nextSibling
          node.appendChild child
          child = next

        for own key, value of innerDomTpl
          if ['frag', 'updaters'].indexOf(key) is -1
            if val[key]?
              innerDomTpl[key] val[key], val, node
        return

    ifnot: (node, attr, done)->
      done()
      innerTpl = node.innerHTML
      log "if-bind to #{node} with #{attr}"
      @_bind attr, (val, valObj)->
        node.innerHTML = ''
        log "if-refrash to #{node} with #{val}"
        if not not val
          return

        innerDomTpl = new Tinywings(innerTpl)
        
        ###
        Copy children elements
        ###
        child = innerDomTpl.frag.firstChild
        while child
          next = child.nextSibling
          node.appendChild child
          child = next

        for own key, value of innerDomTpl
          if key isnt 'frag'
            if valObj[key]?
              innerDomTpl[key] valObj[key], valObj, node
        return

    foreach: (node, attr, done)->
      done()
      innerTpl = node.innerHTML
      log "foreach-bind to #{node} with #{attr}"
      @_bind attr, (val)->
        node.innerHTML = ''
        log "foreach-refrash to #{node} with #{val}"
        for item in val
          innerDomTpl = new Tinywings(innerTpl)
          ###
          Copy children elements
          ###
          child = innerDomTpl.frag.firstChild
          while child
            next = child.nextSibling
            node.appendChild child
            child = next

          for own key, value of innerDomTpl
            if ['frag', 'updaters'].indexOf(key) is -1
              if item[key]
                innerDomTpl[key] item[key], item, node
        return

  Tinywings = (tpl)->
    @updaters = {}
    @frag = document.createElement 'div'
    @frag.innerHTML = tpl
    @preprocess()

  _.extend Tinywings::, Backbone.Events,
    preprocess: ->
      traversal @frag, (node, done)=>
        if node.nodeType is 3
          return @bindTextNode node
        [type, attr] = preprocessBind node
        @bind node, type, attr, done if type? and attr?
        return
      return
    bind: (node, type, attr, done)->
      buildInBind[type].apply @, [node, attr, done]

    _bind: (attr, updater)->
      first = attr.split('.')[0]
      @updaters[first] or= []
      @[first] or= (val, valObj, parent)->
        for up in @updaters[first]
          up val, valObj, parent
        return

      # it.content
      if attr.indexOf('.') > -1
        attrLink = attr.split '.'
        first = attrLink.shift()
        @updaters[first].push (val, valObj, parent)->
          for atr in attrLink
            val = val[atr]
          updater val, valObj, parent
          return

      # content
      else
        @updaters[first].push updater
      return
    bindTextNode: (node)->
      if not /{{[^}]*}}/.test node.data
        return
      log "text-bind to #{node}"
      matches = node.data.match /{{[^}]*}}/g

      tempObj = {}
      for match in matches
        tempObj[match] = match
      matches = Object.keys tempObj

      newData = node.data
      parent = node.parentNode
      for match in matches
        [bind, attr] = /{{([^}]*)}}/.exec match
        newData = newData.replace new RegExp(bind, 'g'), "<!-- data-bind='_text:#{attr}' -->#{bind}<!-- -->"

        do (attr, parent)=>
          @_bind attr, (val, valObj, p)->
            p or= parent
            nodes = p.childNodes
            for node in nodes
              if node.data? and node.data.indexOf("data-bind='_text:#{attr}'") > -1
                node.nextSibling.data = val
                log "text-refrash to #{node} with #{val}"
            return

      newNode = document.createElement('div')
      newNode.innerHTML = newData

      ###
      Replce origin text node
      ###
      first = child = newNode.firstChild
      while child
        next = child.nextSibling
        if child is first
          parent.replaceChild child, node
        else
          if parent.lastChild is last
            parent.appendChild child
          else
            parent.insertBefore child, last.nextSibling
        last = child
        child = next

      return

    appendTo: (el)->
      child = @frag.firstChild
      while child
        next = child.nextSibling
        el.appendChild child
        child = next
      @

    bindModel: (model)->
      data = model.toJSON()
      @render data
      for own attr of data
        if  attr of @
          do (attr)=>
            @listenTo model, "change:#{attr}", =>
              data = model.toJSON()
              @[attr] data[attr], data
      @

    unbindModel: (model)->
      @stopListening model

    render: (model)->
      for own key, value of @
        if ['frag', 'updaters'].indexOf(key) is -1
          @[key] model[key], model
      @

  (tpl)->
    new Tinywings(tpl)
