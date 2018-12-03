# EatWhat
最近比较闲开始学习煮粥，买了好多米和豆子，每天煮的都不一样，试了几天发现有的时候记不住要煮什么粥，所以就写了这个APP。  
每天煮粥的时候拿出来看看就可以了，再也不用思考半天要煮什么粥了。

## 首页
上面显示所有的食材，下面显示的今日计划，所有颜色都为随机的，通过底部按钮可以切换颜色

## 详情页
点击首页左上角按钮进入记录页面，点击右上角箭头进入bing壁纸页面
#### 记录
从本地读取csv文件，并拼接html通过wkwebview显示出来；  
点击某一行删除数据，从本地删除和从html中删除；  
wkwebview和js交互：js调用native方法删除本地数据，native调用js方法删除html中列表项；  
#### bing壁纸
因为我的电脑壁纸时bing壁纸，每天可以换的，有时候又好看的壁纸但是不知道是什么，所有就有这个页面了；  
先获取整个html，解析出描述和图片链接，在加载图片并在底部加上描述；  
这样就可以在手机上看bing壁纸的描述了，长按还可以保存图片到本地（wkwebview自带的，添加plist隐私描述即可实现）；  


是不是很好用，哈哈；  

## 欢迎下载使用
