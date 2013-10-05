# Tinywings

debug = false

log = ->
  if debug
    console.log.apply console, arguments

travel = (node, callback)->
  node = node.firstChild
  stop = false
  done = ->
    stop = true
  while node
    log "travel #{node}"
    next = node.nextSibling
    callback node, done
    if not stop
      travel node, callback
    node = next
  return

# Preprocess node bind-data
preprocess = (node)->

bind = (tw, attr, up)->
  firstAttr = attr.split('.')[0]
  tw.updaters[firstAttr] = tw.updaters[firstAttr] or []
  tw[firstAttr] = tw[firstAttr] or (val, o, parent)->
    for updater in tw.updaters[firstAttr]
      updater val, o, parent
    return

  # it.content
  if attr.indexOf('.') > -1
    attrLink = attr.split '.'
    firstAttr = attrLink.shift()
    tw.updaters[firstAttr].push (val, o, parent)->
      for atr in attrLink
        val = val[atr]
      up val, o, parent
      return

  # content
  else
    tw.updaters[firstAttr].push up
  return

BOOLEAN_ATTRIBUTES = ['disabled', 'readonly']

tinywings = (tpl)->
  log 'START BIND'
  tw = {}
  frag = document.createElement 'div'
  frag.innerHTML = tpl
  tw.frag = frag
  tw.updaters = {}
  travel frag, (node, done)->
    if node.dataset?.bind
      binder = node.dataset.bind
      binder = binder.split ':'
      type = binder.shift()
      attr = binder.join ':'
      switch type
        when 'text'
          log "text-bind to #{node} with #{attr}"
          bind tw, attr, (val)->
            node.innerHTML = val + ''
            log "text-refrash to #{node} with #{val}"

        when 'attr'
          log "attr-bind to #{node} with #{attr}"
          attr = JSON.parse attr
          for key, value of attr
            if BOOLEAN_ATTRIBUTES.indexOf(key) > -1
              do (key, value)->
                bind tw, value, (val)->
                  if BOOLEAN_ATTRIBUTES.indexOf(key) > -1
                    node[key] = not not val
                  else
                    node[key] = val
                  log "attr-refrash to #{node} with #{val}"

        when 'value'
          log "value-bind to #{node} with #{attr}"
          bind tw, attr, (val)->
            node.value = val
            log "value-refrash to #{node} with #{val}"

        when 'if'
          done()
          innerTpl = node.innerHTML
          log "if-bind to #{node} with #{attr}"
          bind tw, attr, (val, o)->
            node.innerHTML = ''
            log "if-refrash to #{node} with #{val}"
            if not val
              return

            innerDomTpl = tinywings innerTpl

            # copy children elements
            child = innerDomTpl.frag.firstChild
            while child
              next = child.nextSibling
              node.appendChild child
              child = next

            for own key, value of innerDomTpl
              if key isnt 'frag'
                if o[key]?
                  innerDomTpl[key] o[key], o, node
            return

        when 'ifnot'
          done()
          innerTpl = node.innerHTML
          log "if-bind to #{node} with #{attr}"
          bind tw, attr, (val, o)->
            node.innerHTML = ''
            log "if-refrash to #{node} with #{val}"
            if not not val
              return

            innerDomTpl = tinywings innerTpl

            # copy children elements
            child = innerDomTpl.frag.firstChild
            while child
              next = child.nextSibling
              node.appendChild child
              child = next

            for own key, value of innerDomTpl
              if key isnt 'frag'
                if o[key]?
                  innerDomTpl[key] o[key], o, node
            return

        when 'with'
          done()
          innerTpl = node.innerHTML
          log "with-bind to #{node} with #{attr}"
          bind tw, attr, (val)->
            node.innerHTML = ''
            log "foreach-refrash to #{node} with #{val}"
            innerDomTpl = tinywings innerTpl

            # copy children elements
            child = innerDomTpl.frag.firstChild
            while child
              next = child.nextSibling
              node.appendChild child
              child = next

            for own key, value of innerDomTpl
              if key isnt 'frag'
                if val[key]?
                  innerDomTpl[key] val[key], val, node
            return

        when 'foreach'
          done()
          innerTpl = node.innerHTML
          log "foreach-bind to #{node} with #{attr}"
          bind tw, attr, (val)->
            node.innerHTML = ''
            log "foreach-refrash to #{node} with #{val}"
            for item in val
              innerDomTpl = tinywings innerTpl

              # copy children elements
              child = innerDomTpl.frag.firstChild
              while child
                next = child.nextSibling
                node.appendChild child
                child = next

              for own key, value of innerDomTpl
                if key isnt 'frag'
                  if item[key]
                    innerDomTpl[key] item[key], item, node
            return
    else if node.nodeType is 3 and /{{[^}]*}}/.test node.data
      log "text-bind to #{node}"
      matches = node.data.match /{{[^}]*}}/g
      o = {}
      for match in matches
        o[match] = match
      matches = Object.keys o
      newData = node.data
      parent = node.parentNode
      for match in matches
        [binder, attr] = /{{([^}]*)}}/.exec match
        newData = newData.replace new RegExp(binder, 'g'), "<!-- data-bind='_text:#{attr}' -->#{binder}<!-- -->"
        # it.content
        do (attr, parent)->
          bind tw, attr, (val, o, p)->
            p or= parent
            nodes = p.childNodes
            for node in nodes
              if node.data? and node.data.indexOf("data-bind='_text:#{attr}'") > -1
                node.nextSibling.data = val
                log "text-refrash to #{node} with #{val}"
            return

      newNode = document.createElement('div')
      newNode.innerHTML = newData
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
  log 'END BIND'
  tw

if Backbone?
  Backbone.tinywings = tinywings
else
  @.tinywings = tinywings
