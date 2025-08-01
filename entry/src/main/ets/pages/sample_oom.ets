/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { InlineContentParser, ParsedInline, parseIntoJsNode, printNode, Scanner } from '@cangjie-tpc/markdown_hybrid';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';

export async function OutOfMemoryError(page: object): Promise<void> {
  let md = page['spec'] as string
  let i = 0
  let tid = setInterval(() => {
    if (i % 100 == 0) {
      page['message'] = `i:${i}`
    }
    parseIntoJsNode(md)
    i += 1
    if (i >= md.length) {
      clearInterval(tid)
    }
  }, 10)
}

export async function SharedHeap_OOM(page: object): Promise<void> {
  let md = page['spec'] as string

  for (let i = 0; i < md.length; i++) {
    if (i % 100 == 0) {
      page['message'] = `i:${i}`
    }
    await parseIntoJsNode(md)
  }
}

/**
cj parseIntoJsNode error: Error: OutOfMemoryError
 at ohos.ark_interop.JSString::readString(ohos.ark_interop::JSContext, ohos.ark_interop::JSValue_)(jsstring.cj:88)
 at ohos.ark_interop.JSValue::toString(ohos.ark_interop::JSContext)(js_raw.cj:468)
 at markdown_hybrid.parseIntoJsNode(ohos.ark_interop::JSContext, ohos.ark_interop::JSCallInfo)(D:\tmp\markdown511821\markdown_hybrid\src\main\cangjie/parse_into_js_node.cj:97)
 at ohos.ark_interop.cjLambdaInvoker(ohos.ark_interop::JSCallInfoPrivate, Int64)(js_func.cj:106)
 Cannot get SourceMap info, dump raw stack:
 at parseIntoJsNode (entry|@cangjie-tpc/markdown_hybrid|1.2.6|Index.ts:10:1)
 at anonymous (entry|entry|1.0.0|src/main/ets/pages/sample_oom.ts:9:1)

 Reason:Signal:SIGABRT(SI_TKILL)@0x01317b4c000027fd from:10237:20020044
 LastFatalMessage:[gc] SharedHeap OOM

 Reason:Signal:SIGSEGV(SEGV_MAPERR)@0x000000000000000e  probably caused by NULL pointer dereference

 Reason:Signal:SIGSEGV(SEGV_MAPERR)@0x0000003c00000008

 Reason:Signal:SIGABRT(SI_TKILL)@0x01317b4c0000190f from:6415:20020044
 */