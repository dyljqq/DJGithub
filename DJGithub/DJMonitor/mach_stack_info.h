//
//  mach_stack_info.h
//  DJMonitor
//
//  Created by jiqinqiang on 2022/10/21.
//

#ifndef mach_stack_info_h
#define mach_stack_info_h

#include <mach/mach.h>

int mach_frame_count(thread_t thread, void **stack, int maxSymbolCount);

#endif /* mach_stack_info_h */
