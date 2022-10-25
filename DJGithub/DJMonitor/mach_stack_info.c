//
//  mach_stack_info.c
//  DJMonitor
//
//  Created by jiqinqiang on 2022/10/21.
//

#include "mach_stack_info.h"
#include <stdio.h>
#include <stdlib.h>
#include <machine/_mcontext.h>

/**
 
 Stack frame structure for arm/arm64:
 *
 *    | ...                   |
 *    +-----------------------+ hi-addr     ------------------------
 *    | func0 lr              |
 *    +-----------------------+
 *    | func0 fp              |--------|     stack frame of func1
 *    +-----------------------+        v
 *    | saved registers       |  fp <- sp
 *    +-----------------------+   |
 *    | local variables...    |   |
 *    +-----------------------+   |
 *    | func2 args            |   |
 *    +-----------------------+   |         ------------------------
 *    | func1 lr              |   |
 *    +-----------------------+   |
 *    | func1 fp              |<--+          stack frame of func2
 *    +-----------------------+
 *    | ...                   |
 *    +-----------------------+ lo-addr     ------------------------
 
 获取这个线程一共有多少栈帧
 @param thread 线程
 @param stack 栈
 @param maxSymbolCount 最多输出多少调用记录
 */
int mach_frame_count(thread_t thread, void **stack, int maxSymbolCount) {
  _STRUCT_MCONTEXT machineContext;
  mach_msg_type_number_t stateCount = ARM_THREAD_STATE64_COUNT;
  
  kern_return_t kerr = thread_get_state(thread,
                                        ARM_THREAD_STATE64,
                                        (thread_state_t)&(machineContext.__ss),
                                        &stateCount);
  if (kerr != KERN_SUCCESS) {
    return 0;
  }
  
  int i = 0;
  stack[i++] = (void *)machineContext.__ss.__pc;
  stack[i++] = (void *)machineContext.__ss.__lr;

  void **currentFramePointer = (void **)machineContext.__ss.__fp;
  while (i < maxSymbolCount) {
    void **previous = *currentFramePointer;
    if (!previous) break;;
    stack[i++] = *(currentFramePointer + 1);
    currentFramePointer = previous;
  }
  return i;
}
