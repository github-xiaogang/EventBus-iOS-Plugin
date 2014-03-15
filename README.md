EventBus-iOS-Plugin
===================

a Xcode plug-in for another repository (EventBus-iOS)


插件安装(install)：
===================

  copy EventBus-iOS.xcplugin to ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/
  
  or build target <EventBus-iOS> , after build, Xcode will help you copy the plug-in product to that directory,
  
  then that you should restart Xcode ,let Xcode load the plug-in.

使用：
===================


按 ctrl + e 会列出所有发布过的事件。

1.选中其中一项，它会将eventName插入到代码中。

2.选中时同时按ctrl ，它会帮你找到发布该事件的地方。

usage:
===================

press ctrl + e to show all published event , then


1. when you select one item ,it will auto insert the selected eventName to your code.
2. when you hold ctrl key ,then select one item ,it will help you find where this event was defined.

注：
===================

编写插件时参考了 onevcat 的博文：http://onevcat.com/2013/02/xcode-plugin/ 和 trawor( http://weibo.com/trawor ) 的插件 XToDo : https://github.com/trawor/XToDo
