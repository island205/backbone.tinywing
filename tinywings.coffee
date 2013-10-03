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
    callback node, done
    if not stop
      travel node, callback
    node = node.nextSibling

tinywings = (tpl)->
  log 'START BIND'
  tw = {}
  frag = document.createElement 'div'
  frag.innerHTML = tpl
  tw.frag = frag
  travel frag, (node, done)->
    if node.dataset?.bind
      bind = node.dataset.bind
      [type, attr]= bind.split ':'
      switch type
        when 'text'
          log "text-bind to #{node} with #{attr}"
          # it.content
          if attr.indexOf('.') > -1
            attrLink = attr.split '.'
            firstAttr = attrLink.shift()
            tw.attrLinkCb = tw.attrLinkCb or {}
            tw.attrLinkCb[firstAttr] = tw.attrLinkCb[firstAttr] or []
            tw.attrLinkCb[firstAttr].push (val)->
              for atr in attrLink
                val = val[atr]
              node.innerHTML = val
              log "text-refrash to #{node} with #{val}"

            tw[firstAttr] = (val)->
              for callback in tw.attrLinkCb[firstAttr]
                callback val
          else
            tw[attr] = (val)->
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
                    innerDomTpl[key] item[key]
            return
    return
  log 'END BIND'
  tw

# Test
# knockout tpl syntax

tpl = '''
  <div data-bind="text:text">
  </div>
  <p data-bind="text:content"></p>
'''

tpl1 = '''
  <div data-bind="foreach:people"><p data-bind="text:content"></p><p data-bind="text:name"></p><div data-bind="foreach:pens"><p data-bind="text:color"></p></div></div>
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
    domTpl.text 'something like this'
    domTpl.content 'more'

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

  test1()
  test2()
  test3()
