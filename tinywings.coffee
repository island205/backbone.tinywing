# Tinywings

debug = true

log = ->
  if debug
    console.log.apply console, arguments

travel = (node, callback)->
  node = node.firstChild
  while node
    callback node
    log "travel #{node}"
    travel node, callback
    node = node.nextSibling

tinywings = (tpl)->
  tw = {}
  frag = document.createElement 'div'
  frag.innerHTML = tpl
  tw.frag = frag
  travel frag, (node)->
    console.log node
    if node.dataset?.bind
      bind = node.dataset.bind
      [type, attr]= bind.split ':'
      switch type
        when 'text'
          tw[attr] = (val)->
            node.innerHTML = val
            log "text-bind to #{node} with #{val}"
        when 'foreach'
          innerTpl = node.innerHTML
          tw[attr] = (val)->
            node.innerHTML = ''
            log "foreach-bind to #{node} with #{val}"
            for item in val
              innerDomTpl = tinywings innerTpl
              node.appendChild innerDomTpl.frag.firstChild
              for own key, value of innerDomTpl
                if key isnt 'frag'
                  if item[key]
                    innerDomTpl[key] item[key]
            return
    return
  tw

# Test
# knockout tpl syntax

tpl = '''
  <div data-bind="text:text">
  </div>
'''

tpl1 = '''
  <div data-bind="foreach:people"><p data-bind="text:text"></p></div>
'''


domTpl = tinywings tpl
domTpl1 = tinywings tpl1

window.onload = ->
  document.body.appendChild domTpl.frag.firstChild
  document.body.appendChild domTpl1.frag.firstChild

  domTpl.text('something like this')
  setTimeout ->
    domTpl.text 'changed after 5s'
  ,
  5000

  domTpl1.people [
    {text:'xxx'}
    {text:'x'}
  ]

  setTimeout ->
    domTpl1.people [
      {text:'xxx'}
      {text:'xxxx'}
      {text:'x'}
    ]
  ,
  5000
