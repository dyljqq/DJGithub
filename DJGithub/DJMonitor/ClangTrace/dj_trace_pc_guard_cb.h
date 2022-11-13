//
//  dj_trace_pc_guard_cb.h
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/14.
//

#ifndef dj_trace_pc_guard_cb_h
#define dj_trace_pc_guard_cb_h

#include <stdio.h>

typedef struct {
    void *pc;
    void *next;
} SymbolNode;

// This callback is inserted by the compiler as a module constructor
// into every DSO. 'start' and 'stop' correspond to the
// beginning and end of the section with the guards for the entire
// binary (executable or DSO). The callback will be called at least
// once per DSO and may be called multiple times with the same parameters.
void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                         uint32_t *stop);

// This callback is inserted by the compiler on every edge in the
// control flow (some optimizations apply).
// Typically, the compiler will emit the code like this:
//    if(*guard)
//      __sanitizer_cov_trace_pc_guard(guard);
// But for large functions it will emit a simple call:
//    __sanitizer_cov_trace_pc_guard(guard);
void __sanitizer_cov_trace_pc_guard(uint32_t *guard);

#endif /* dj_trace_pc_guard_cb_h */
