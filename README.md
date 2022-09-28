# 开源的Github客户端

方便自己去看一些开源项目以及一些咨询。

### 配置

在/DJGithub/Github/目录下添加config.plist文件，App启动的时候会读取用户的Personal Token.

例：

"Authorization": "token \\(Personal Token)"

### 目前进度：

2022-09-15

1. 网络库以及一些常用方法的封装。
2. 开始绘制Github用户界面

2022-09-16

1. 完善用户界面
2. 接入User Contribution的数据
3. 用户Star的Repo列表

2022-09-17 （待完成）

1. 刷新机制
2. 语言的颜色展示，目前暂时没有发现从github上获取语言颜色的接口

​	目前想到的方案是，发现一种新的语言，给定一个随机的颜色，并保存到本地。

2022-09-28

1. 修复上拉刷新视图不显示的bug
2. 添加following users的列表
3. 添加follow功能，抽象剥离follow跟star组件 (单击star或者follow button的时候，会有一个网络请求跟状态变更的过程)

### TODO

1. 继续基础界面的搭建
2. 完善页面跳转方案

ps：

无比怀念声明式布局。从SwiftUI or Flutter回到纯Swift代码布局，有种当年从OC转Swift的感觉。