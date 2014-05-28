# Backbone.tinywings

为Backbone添加一个小翅膀，将Model单项绑定到View。

## 介绍

Backbone本身并没有自己的模板引擎，借助`_.template`等其他一些模板引擎，实现将Model渲染到View中。但是：

> 1. 每次数据变化都要全部`render`有没有？

> 2. 频繁的创建或删除DOM；

> 3. 代码改怎么写，频繁调用`render`函数，很不**make sence**。

Backbone.tinywings将模板转换成DOM，通过DOM方法来修改DOM，在Model变化时，对View的更新非常轻量；关键的是：

1. 只有一次DOM创建；
2. 只调一次`render`方法；
3. Model变化时，自动更新与View的数据。

Backbone.tinywings采用了与AngularJS类似的模板语法。

最后，非常傲娇地使用了[CoffeeScript](http://coffeescript.org/)。

## 如何使用

Backbone.**tinywings(tpl)**

编译模板，将模板转化为可根据属性值更新的DOM。

```html
<script type="text/template" id="item-template">
	<div class="view">
		<input class="toggle" type="checkbox" data-bind='attr:{"checked": "completed"}'>
		<label data-bind="text:title"></label>
		<button class="destroy"></button>
	</div>
	<input class="edit" data-bind="value:title">
</script>
```

```javascript
// 构建模板
var tw = Backbone.tinywings($('#item-template').html())

// 数据更新
tw.title('别忘了买盐')
```

**tw.render(data)**

更新view。

```javascript
tw.render({
	title: '别忘了买盐',
	completed: false
})
```

**tw.bindModel(model)**

将view绑定到model（Backbone的`Model`实例），当`model`有变化时，自动更新view。

```javascript
tw.bindModel(model)
```

**tw.unbindModel(model)**

view与model解绑定。

```javascript
tw.unbindModel(model)
```

**tw.appendTo(node)**

将view添加到DOM树中。

```javascript
tw.appendTo($('#todos'))
```


## 模板语法

### 值绑定

**tw-text**

```html
<label tw-text="title"></label>
```

在`label`中显示`title`的值。

**tw-value**

```html
<input class="edit" tw-value="title">
```

绑定到表单元素的`value`。

**{{}}**

```html
<span> {{title}} This is a inline bind.</span>
```

文本节点中的值绑定。

### 流控制命令

**tw-if**

```html
<div tw-if="title">
	{{title}}
</div>
```

**tw-repeat**

```html
<ul tw-repeat="todo in todos">
	<li>{{todo.title}}</li>
</ul>
```

### 样式指令

**tw-class**

还包括：`tw-class-odd` 和 `tw-class-even`

```html
<div tw-class="modal"></div>

<div tw-class="{modal: isModal}"></div>

<tr tw-class-odd="red-line"></tr>
```

**tw-style**

```html
<div tw-style="styleInModel"></div>
```

**tw-hide tw-show**

通过这两个命令，来控制元素的显示和影藏

```html
<div tw-show="isNeedShow"></div>
```

### 表单控件相关的指令

- tw-checked
- tw-selected
- tw-disabled
- tw-readonly

### 其他指令

- tw-href
- tw-src

## 示例

[backbone-todomvc-with-tinywings](https://github.com/island205/todomvc/tree/gh-pages/architecture-examples/backbone-with-tinywings)

## 性能测试

[http://jsperf.com/tinywings-vs-template](http://jsperf.com/tinywings-vs-template) （目前很渣）


## 更新

#### v0.1.0

实现一些基本的绑定；
结合一些Backbone的项目，优化可用性和性能。