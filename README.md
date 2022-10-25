# 开源的Github客户端

方便自己去看一些开源项目以及一些RSS订阅功能。纯Swift编写。

有任何问题欢迎提issue or [gmail](qinqiangji@gmail.com)

### 配置

在/DJGithub/Github/Resource/config.json文件中补充对应的配置信息.

Personal access tokens的申请链接如下：

[Personal access tokens](https://github.com/settings/tokens) 

申请的时候注意看用户的权限信息，如果某些权限没有选择的话，可能会造成app内容无法成功获取。具体以返回数据信息为准。

例:

```json
{
 "authorization": "token \(personal token)", // person token
}
```

如果Swift Package fetch过慢的话，可以使用以下命令行指令：

```
xcodebuild -resolvePackageDependencies -scmProvider system
```



### 库介绍

一些使用技巧与技术介绍。

1. 关于DJGithub相关的网络数据下载与解析的模块可以看这篇文章：

   * 掘金地址：[如何使用异步方法构造一个简易的网络请求库 ](https://juejin.cn/post/7153533145168478245)
   
   * github地址： [如何使用异步方法构造一个简易的网络请求库 ](https://github.com/dyljqq/Article/blob/master/Swift/%E4%BD%BF%E7%94%A8swift%E6%9E%84%E9%80%A0%E4%B8%80%E4%B8%AA%E5%BC%82%E6%AD%A5%E7%9A%84%E7%BD%91%E7%BB%9C%E6%95%B0%E6%8D%AE%E8%AF%B7%E6%B1%82%E7%B1%BB.md)

### 已完成功能

1. 获取，修改用户信息

2. 获取库信息

  * 库基本信息
  * 库文件信息的读取与展示
  * 库start，watches，forks，contributors列表展示
  * 库issue & issue comment的获取，展示，修改
  * README通过webview去渲染
  * 获取库信息的pull request
  * 刷新README

3. 登录用户的star repos的获取&展示

4. 库与用户的相关信息的检索，并设置历史搜索词。

5. 接入一些SwiftPamphletApp中的本地相关文件，里面有一些常用，精选的iOS开发相关的内容。[SwiftPamphletApp](https://github.com/KwaiAppTeam/SwiftPamphletApp)

6. 添加User feeds相关的内容

   * 解析XML数据，自定义XML解析器
	
   * 因为Feed数据中会包含多个库跟用户信息，因此给这些文字做了高亮与点击操作。

7. 加入Rss源的解析。

   1. 界面的搭建以及数据解析框架的搭建

   2. Rss阅读体验优化，增加阅读状态。

   待完成：
   
   * 接入不同Rss源数据(已完成)
   * 数据做本地存储的操作(已完成)
   * Rss中content内容的展示（已完成）
   
8. 性能优化检测

    * 卡顿优化检测

      1. 使用runloop去检测卡顿出现的时机
      2. 打印主线程的调用栈（swift通过dl_info结构，可以很方便的输出我们想要的信息）

      具体的实现可以看DJMonitor目录下的实现。

### 待完成(目前想到的)

1. repo pull request的相关信息的展示以及相关的code review， merge等操作
2. 剥离github api相关的代码，方便其他开发者调用
3. 一些功能组件的剥离与重构，比如refresh，网络模块等。
4. 接入一些常见的rss订阅源。
4. 增加rss文章的收藏功能。可能可以增加文件夹？



### APP展示

| <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/LocalDeveloper.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/Stars.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/SearchHistory.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/SearchResults.png" width="190" height="335"/> |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/User.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/UserInteract.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/UserInfo.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/Repo.png" width="190" height="335"/> |
| <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/RepoDir.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/RepoIssues.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/IssueDetail.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/EditIssue.png" width="190" height="335"/> |
| <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/IssueComments.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/Feeds.png" width="190" height="335"/> | <img src="https://raw.githubusercontent.com/dyljqq/DJGithub/master/screenshot/RssFeeds.png" width="190" height="335"/> |                                                              |





### 目前进度：

##### 2022-09-15

1. 网络库以及一些常用方法的封装。
2. 开始绘制Github用户界面

##### 2022-09-16

1. 完善用户界面
2. 接入User Contribution的数据
3. 用户Star的Repo列表

##### 2022-09-17 （待完成）

1. 刷新机制
2. 语言的颜色展示，目前暂时没有发现从github上获取语言颜色的接口

​	目前想到的方案是，发现一种新的语言，给定一个随机的颜色，并保存到本地。

##### 2022-09-28

1. 修复上拉刷新视图不显示的bug
2. 添加following users的列表
3. 添加follow功能，抽象剥离follow跟star组件 (单击star或者follow button的时候，会有一个网络请求跟状态变更的过程)

##### 2022-09-29

1. 剥离替换star button 跟 follow button。

​	举个例子，star跟follow的操作其实是一样的，不管是视图的布局，样式等等。因此我们只需要定义一个enum：

```swift
enum UserStatusViewType {
  case follow(String)
  case star(String)
  case unknown
  
  func getActiveContent(isActive: Bool) -> String {
    switch self {
    case .follow: return isActive.followText
    case .star: return isActive.starText
    case .unknown: return ""
    }
  }
}
```

根据具体的枚举值做对应的操作即可。

2. 添加Repo的watches，stars，forks的列表页。剥离&抽象&复用
3. 添加User的following，followers等列表页

##### 2022-09-30

1. 添加用户follow状态。具体的方案如下:

```
1. App启动时默认加载一千条用户的follow状态，并通过UserFollowingManager管理对应的缓存。
2. 当加载用户列表的时候，异步加载用户是否被follow。
	* 从内存中获取
	* 如果不在内存中，则异步加载获取
3. 当用户follow跟unfollow操作的时候，去修改缓存数据。
```

这个方案有点问题，就是当用户在其他的App进行follow跟unfollow的操作时，该App无法做及时的修改。

##### 2022-10-01

1. 添加搜索模块（用户搜索&库搜索）

 TODO:

	1. 保存历史搜索词
	1. 增加对应的界面

##### 2022-10-04

1.  添加repo的文件展示功能
2. 添加查看repo issues的功能

​	目前只做了issues列表，详情的话还在添加

##### 2022-10-05

1. 添加issues评论，列表经过思考之后还是决定采用web的形式去展示。

	* 接口返回的body是md形式的文本，如果列表渲染每个cell的md文本的话，性能会消耗的非常厉害。而且会有一些样式的问题。因此issue的详情通过原生，列表采用web展示

2. webView添加back，forward，reload action。

TODO:

1. Create new issue & new issue comment
1. rss read parse

##### 2022-10-06

1. 添加创建issue的界面
2. 封装HUD & UITextView + Placeholder
2. issue & issue comment的交互

TODO：

1. 查看repo的pull情况。
2. 添加本地的repo

##### 2022-10-07

1. 添加本地Repo
2. 抽象本地Devlopers，共用一个vc
3. 用户界面细节跟交互调整

TODO:

1. 为什么本地Repo不去同步更新信息呢？因为数据量有点大，而且添加图片跟是否star不是非常关键。因为Desc有一个比较简易的说明。具体可以点击进去观看repo的具体信息。

##### 2022-10-08

1. 增加用户信息的修改与展示

##### 2022-10-09

1. 一些bug的修复
2. 统一网络请求返回数据的xml与json数据的解析。

##### 2022-10-10

1. 重构xml解析代码，能够兼容更多的xml内容
2. 添加user feeds相关的界面跟内容

TODO：

通过xml解析出的文本，确定feed将要跳转的地方，目前已知的是一条feed entry会有：

starred， forked， createRepository，release， added to，这些都会带repo相关的内容。后面会思考如何更简便的去解析出这些文本的内容。

### TODO

1. 继续基础界面的搭建
2. 完善页面跳转方案
2. 添加用户界面的交互功能
2. 添加判定是不是owner，根据这个隐藏对应的视图。
2. 如何动态的展示登录用户对不同用户的follow状态。比如说，在followers页面，会存在follow的用户跟unfollow的用户，那么如何展示follow button的状态呢？

​	Github上有一个api可以check单个用户的是否被follow，但是对于列表来说，如果不断的去调用这个接口的话，是否会有问题？是否可以通过在本地缓存follow状态？

​	现在有两个方案：

* 方案一：首先在App启动时，去拉取所有的follow列表，然后进行缓存，当用户在App上做follow or unfollow的操作的时候，去修改对应的值。并去check这个值是否正确？
* 方案二：在滑动的时候，去获取对应的follow的信息。然后通过一个全局变量来缓存这个信息。



ps：

无比怀念声明式布局。从SwiftUI or Flutter回到纯Swift代码布局，有种当年从OC转Swift的感觉。