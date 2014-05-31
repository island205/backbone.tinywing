# Test
# knockout tpl syntax

tpl = '''
  <div tw-text="text">
  </div>
  <p tw-text="content"></p>
  <p>this is inline {{content}} bind.<input tw-value="content"/></p>
  <p>this is inline {{it.content}} bind and {{content}} bind.</p>
  <p tw-if="showIt"><span tw-text="it.content"></span><span tw-text="showIt"></span> is true</p>
'''

tpl1 = '''
  <div tw-repeat="peoples">this is {{content}}  and {{name}}.<p tw-text="content"></p><p tw-text="name"></p><div tw-repeat="pens"><p tw-text="color"></p></div></div>
'''

tpl2 = '''
  <div tw-text="it.text">
  </div>
  <p tw-text="it.content"></p>
  <p tw-text="it.content"></p>
  <p tw-text="that.content"></p>
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
      peoples:[
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
