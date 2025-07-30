/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { parseIntoJsNode, printNode, JsNode } from '@cangjie-tpc/markdown_hybrid';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function sample_test2(page: object) {
  let md = page['test2md'] as string
  for (let i = 0; i < md.length; i++) {
    let mdstr = md.slice(0, i)
    let node = await parseIntoJsNode(mdstr)
    let nodeTreeStr = printNode(node)
    page['message'] = nodeTreeStr
    hilog.error(0,'mdebug',`test2: ${i} ${mdstr.length} ${nodeTreeStr.length}`)
  }
}
