# Test
# knockout tpl syntax

tpl = '''
  <div data-bind="text:text">
  </div>
  <p data-bind="text:content"></p>
  <p>this is inline {{content}} bind.<input data-bind="value:content"/><input value="disabled" data-bind='attr:{"disabled": "content"}' /></p>
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