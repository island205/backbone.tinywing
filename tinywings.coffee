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
    if node.dataset.bind
      bind = node.dataset.bind
      bind = bind.split ':'
      tw[bind[1]] = (val)->
        if bind[0] is 'text'
          node.innerHTML = val
          console.log val
     return
  tw

# Test

tpl = '''
  <div data-bind = 'text:text'></div>
'''

domTpl = tinywings tpl

domTpl.text 'something like this'
