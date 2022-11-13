//
//  DJClangeTrace.m
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/14.
//

#import "DJClangTrace.h"
#import "dj_trace_pc_guard_cb.h"
#import <dlfcn.h>
#import <libkern/OSAtomic.h>

extern OSQueueHead symbolList;

@implementation DJClangTrace

+ (void)generateOrderFile {
  NSMutableArray <NSString *> *symbolNames = [NSMutableArray array];
  while (YES) {
      SymbolNode *node = OSAtomicDequeue(&symbolList, offsetof(SymbolNode, next));
      if (node == NULL) { break; }
      Dl_info info;
      dladdr(node->pc, &info);
      NSString *name = @(info.dli_sname);
      // 判断是不是oc方法，是的话直接加入符号数组
      BOOL isObjc = [name hasPrefix:@"-["] || [name hasPrefix:@"+["];
      /* 非oc方法，一般会加上一个'_'，这是由于UNIX下的C语言规定全局的变量和函数经过编译后
         会在符号前加下划线从而减少多种语言目标文件之间的符号冲突的概率；
         可以通过编译选项'-fleading-underscore'开启、'-fno-leading-underscore'来关闭
       */
      NSString * symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
      [symbolNames addObject:symbolName];
  }
  
  // 取反:将先调用的函数放到前面
  NSEnumerator *emt = [symbolNames reverseObjectEnumerator];
  // 去重：由于一个函数可能执行多次，__sanitizer_cov_trace_pc_guard会执行多次，就加了重复的了，所以去重一下
  NSMutableArray<NSString *> *funcs = [NSMutableArray arrayWithCapacity:symbolNames.count];
  NSString *name;
  while (name = [emt nextObject]) {
      if (![funcs containsObject:name]) {
          [funcs addObject:name];
      }
  }
  // 由于trace了所有执行的函数，这里我们就把本函数移除掉
  [funcs removeObject:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  // write order file
  NSString *funcStr = [funcs componentsJoinedByString:@"\n"];
  NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"trace.order"];
  NSData *fileContents = [funcStr dataUsingEncoding:NSUTF8StringEncoding];
  [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
  
  #if DEBUG
  NSLog(@"\n\norder file path:\n\n%@\n\n%@", filePath, funcStr);
  #endif
}

@end
