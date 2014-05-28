# Test
# knockout tpl syntax

tpl = '''
  <div data-bind="text:text">
  </div>
  <p data-bind="text:content"></p>
  <p>this is inline {{content}} bind.<input data-bind="value:content"/></p>
  <p>this is inline {{it.content}} bind and {{content}} bind.</p>
  <p data-bind="if:showIt"><span data-bind="text:it.content"></span><span data-bind="text:showIt"></span> is true</p>
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
    domTpl = Backbone.tinywing tpl
    domTpl.appendTo document.body
    o =
      text: 'something like this'
      content: 'more'
      showIt: false
      it:
        content: 'it.content'
    domTpl.render o

  test2 = ->
    domTpl1 = Backbone.tinywing tpl1
    domTpl1.appendTo document.body
    o =
      people:[
        {content:'xxx', name: 'yyyy', pens: []},
        {content:'xxx', name: 'yyy' , pens: []}
      ]
    domTpl1.render o


  test3 = ->
    domTpl = Backbone.tinywing tpl2
    domTpl.appendTo document.body
    o =
      it:
        text:'it.xxxx',
        content: 'it.xxxxxx'
      that:
        content: 'that.xxxxx'
    domTpl.render o

  test1()
  test2()
  test3()
