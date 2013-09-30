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
          log "text-bind to #{node} with #{attr} key"
          tw[attr] = (val)->
            node.innerHTML = val
            log "text-refrash to #{node} with #{val}"
        when 'foreach'
          done()
          innerTpl = node.innerHTML
          log "foreach-bind to #{node} with #{attr} key"
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
'''

tpl1 = '''
  <div data-bind="foreach:people"><p data-bind="text:content"></p><p data-bind="text:name"></p></div>
'''



window.onload = ->
  test1 = ->
    domTpl = tinywings tpl
    document.body.appendChild domTpl.frag.firstChild
    domTpl.text('something like this')
    setTimeout ->
      domTpl.text 'changed after 5s'
    ,
    5000

  test2 = ->
    domTpl1 = tinywings tpl1
    document.body.appendChild domTpl1.frag.firstChild
    domTpl1.people [
      {content:'xxx', name: 'yyyy'}
      {content:'xxx', name: 'yyy'}
    ]

    setTimeout ->
      domTpl1.people [
        {content:'xxx', name: 'yyyy'}
        {content:'xxx', name: 'yyy'}
        {content:'xxx', name: 'clyyy'}
      ]
    ,
    5000

  test2()
