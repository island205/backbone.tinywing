# Tinywings

debug = true

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
      [type, attr]= binder.split ':'
      switch type
        when 'text'
          log "text-bind to #{node} with #{attr}"
          bind tw, attr, (val)->
            node.innerHTML = val + ''
            log "text-refrash to #{node} with #{val}"

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

# Test
# knockout tpl syntax

tpl = '''
  <div data-bind="text:text">
  </div>
  <p data-bind="text:content"></p>
  <p>this is inline {{content}} bind.</p>
  <p>this is inline {{it.content}} bind and {{content}} bind.</p>
  <p data-bind="with:it"><span data-bind="text:content"></span></p>
  <p data-bind="if:showIt"><span data-bind="text:it.content"></span><span data-bind="text:showIt"></span> is true</p>
  <p data-bind="ifnot:showIt"><span data-bind="text:it.content"></span><span data-bind="text:showIt"></span> is false</p>
'''

tpl1 = '''
  <div data-bind="foreach:people">this is {{content}}  and {{name}}.<p data-bind="text:content"></p><p data-bind="text:name"></p><div data-bind="foreach:pens"><p data-bind="text:color"></p></div></div>
'''

tpl2 = '''
  <div data-bind="text:it.text">
  </div>
  <p data-bind="text:it.content"></p>
  <p data-bind="text:it.content"></p>
  <p data-bind="text:that.content"></p>
'''


window.onload = ->
  test1 = ->
    domTpl = tinywings tpl
    document.body.appendChild domTpl.frag.firstChild
    document.body.appendChild domTpl.frag.firstChild.nextSibling
    document.body.appendChild domTpl.frag.firstChild.nextSibling.nextSibling
    document.body.appendChild domTpl.frag.firstChild.nextSibling.nextSibling.nextSibling
    document.body.appendChild domTpl.frag.firstChild.nextSibling.nextSibling.nextSibling.nextSibling
    document.body.appendChild domTpl.frag.firstChild.nextSibling.nextSibling.nextSibling.nextSibling.nextSibling
    document.body.appendChild domTpl.frag.firstChild.nextSibling.nextSibling.nextSibling.nextSibling.nextSibling.nextSibling
    o =
      text: 'something like this'
      content: 'more'
      showIt: false
      it:
        content: 'it.content'
    domTpl.text o.text, o
    domTpl.content o.content, o
    domTpl.it o.it, o
    domTpl.showIt o.showIt, o

  test2 = ->
    domTpl1 = tinywings tpl1
    document.body.appendChild domTpl1.frag.firstChild
    o =
      people:[
        {content:'xxx', name: 'yyyy', pens: []},
        {content:'xxx', name: 'yyy' , pens: []}
      ]
    domTpl1.people o.people, o


  test3 = ->
    domTpl = tinywings tpl2
    document.body.appendChild domTpl.frag.firstChild
    document.body.appendChild domTpl.frag.firstChild.nextSibling
    document.body.appendChild domTpl.frag.firstChild.nextSibling.nextSibling
    document.body.appendChild domTpl.frag.firstChild.nextSibling.nextSibling.nextSibling
    o =
      it:
        text:'it.xxxx',
        content: 'it.xxxxxx'
      that:
        content: 'that.xxxxx'
    domTpl.it o.it, o
    domTpl.that o.that, o

  test1()
  test2()
  test3()
