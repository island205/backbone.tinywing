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

bind = (tw, attr, updater)->
  firstAttr = attr.split('.')[0]
  tw.callbacks[firstAttr] = tw.callbacks[firstAttr] or []
  tw[firstAttr] = tw[firstAttr] or (val, parent)->
    for callback in tw.callbacks[firstAttr]
      callback val, parent
    return

  # it.content
  if attr.indexOf('.') > -1
    attrLink = attr.split '.'
    firstAttr = attrLink.shift()
    tw.callbacks[firstAttr].push (val, parent)->
      for atr in attrLink
        val = val[atr]
      updater val, parent
      return

  # content
  else
    tw.callbacks[firstAttr].push (val, parent)->
      updater val, parent
      return
  return

tinywings = (tpl)->
  log 'START BIND'
  tw = {}
  frag = document.createElement 'div'
  frag.innerHTML = tpl
  tw.frag = frag
  tw.callbacks = {}
  travel frag, (node, done)->
    if node.dataset?.bind
      binder = node.dataset.bind
      [type, attr]= binder.split ':'
      switch type
        when 'text'
          log "text-bind to #{node} with #{attr}"
          bind tw, attr, (val)->
            node.innerHTML = val
            log "text-refrash to #{node} with #{val}"

        when 'foreach'
          done()
          innerTpl = node.innerHTML
          log "foreach-bind to #{node} with #{attr}"
          tw[attr] = (val)->
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
                    innerDomTpl[key] item[key], node
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
          bind tw, attr, (val, p)->
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
    domTpl.text 'something like this'
    domTpl.content 'more'
    domTpl.it
      content: 'it.content'

  test2 = ->
    domTpl1 = tinywings tpl1
    document.body.appendChild domTpl1.frag.firstChild
    domTpl1.people [
      {content:'xxx', name: 'yyyy', pens: []}
      {content:'xxx', name: 'yyy' , pens: []}
    ]


  test3 = ->
    domTpl = tinywings tpl2
    document.body.appendChild domTpl.frag.firstChild
    document.body.appendChild domTpl.frag.firstChild.nextSibling
    document.body.appendChild domTpl.frag.firstChild.nextSibling.nextSibling
    document.body.appendChild domTpl.frag.firstChild.nextSibling.nextSibling.nextSibling
    domTpl.it
      text:'it.xxxx'
      content: 'it.xxxx'
    domTpl.that
      content:'that.xxxx'

  #test1()
  test2()
  #test3()
