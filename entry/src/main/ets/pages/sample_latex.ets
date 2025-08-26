/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { parseIntoJsNode, printNode, JsNode } from './md';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function sample_latex(page: object) {
  let md = '1. 首先将两个 7 组合起来，使用减法：\n' +
    '   \\[7 - \\frac{7}{7}\\]\n' +
    '   计算 \\(\\frac{7}{7}\\) 得 1，所以剩下：\n' +
    '   \\[7 - 1 = 6\\]\n'
  md = page['latex'] as string
  let node = await parseIntoJsNode(md, 0)
  let nodeTreeStr = printNode(node)
  page['message'] = nodeTreeStr
}
