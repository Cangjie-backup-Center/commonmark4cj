/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { parseIntoJsNode, printNode, JsNode } from '@cangjie-tpc/markdown_hybrid';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function sample_footnote(): Promise<string> {
  let md = 'aaa[^1^][^2^][^3^][^4^]\n[^1]:111\n[^]:\n[^2^]:'
  let node = await parseIntoJsNode(md)
  let nodeTreeStr = printNode(node)
  hilog.error(0, '', nodeTreeStr)
  return nodeTreeStr
}
