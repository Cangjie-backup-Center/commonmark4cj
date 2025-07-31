/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { parseIntoJsNode, printNode, JsNode } from '@cangjie-tpc/markdown_hybrid';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function sample_test2(page: object) {
  let md = page['test2md'] as string
  let total1 = 0
  let total2 = 0
  for (let i = 0; i < md.length; i++) {
    let mdstr = md.slice(0, i)
    let node = await parseIntoJsNode(mdstr)
    let nodeTreeStr = printNode(node)
    page['message'] = nodeTreeStr
    total1 += i
    total2 += nodeTreeStr.length
  }
  hilog.error(0, 'mdebug', `test2: ${total1} ${total2}`)
}

function parse(md: string) {
}
