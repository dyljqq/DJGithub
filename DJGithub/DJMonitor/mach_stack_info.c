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

#if defined __i386__
#define THREAD_STATE_FLAVOR x86_THREAD_STATE
#define THREAD_STATE_COUNT  x86_THREAD_STATE_COUNT
#define __framePointer      __ebp
#define __programCounter    __eip
#define __stackPointer      __esp

#elif defined __x86_64__
#define THREAD_STATE_FLAVOR x86_THREAD_STATE64
#define THREAD_STATE_COUNT  x86_THREAD_STATE64_COUNT
#define __framePointer      __rbp
#define __programCounter    __rip
#define __stackPointer      __rsp

#elif defined __arm__
#define THREAD_STATE_FLAVOR ARM_THREAD_STATE
#define THREAD_STATE_COUNT  ARM_THREAD_STATE_COUNT
#define __framePointer      __r[7]
#define __programCounter    __pc
#define __stackPointer      __sp

#elif defined __arm64__
#define THREAD_STATE_FLAVOR ARM_THREAD_STATE64
#define THREAD_STATE_COUNT  ARM_THREAD_STATE64_COUNT
#define __framePointer      __fp
#define __programCounter    __pc
#define __stackPointer      __sp

#else
#error "Current CPU Architecture is not supported"
#endif

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
  mach_msg_type_number_t stateCount = THREAD_STATE_COUNT;
  
  kern_return_t kerr = thread_get_state(thread,
                                        THREAD_STATE_FLAVOR,
                                        (thread_state_t)&(machineContext.__ss),
                                        &stateCount);
  if (kerr != KERN_SUCCESS) {
    return 0;
  }
  
  int i = 0;
  stack[i++] = (void *)machineContext.__ss.__programCounter;
#if defined(__arm__) || defined (__arm64__)
    stack[i++] = (void *)machineContext.__ss.__lr;
#endif
  void **currentFramePointer = (void **)machineContext.__ss.__framePointer;
  while (i < maxSymbolCount && !currentFramePointer) {
    void **previous = *currentFramePointer;
    if (!previous) break;
    stack[i++] = *(currentFramePointer + 1);
    currentFramePointer = previous;
  }
  return i;
}
