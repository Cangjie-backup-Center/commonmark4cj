/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { parseIntoJsNode, printNode, JsNode } from './md';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';

export async function err829(page: object) {
  try {
    let t0 = systemDateTime.getTime()
    let node1 = await parseIntoJsNode(page['errjson1'] as string, 2)
    let node2 = await parseIntoJsNode(page['errmd1'] as string, 2)
    let node3 = await parseIntoJsNode(page['errmd2'] as string, 2)
    let t1 = systemDateTime.getTime() - t0
    let md2 = printNode(node2)
    page['message'] = `${t1}
    errjson1:${printNode(node1).length}
    errmd1:${md2.length}
    errmd2:${printNode(node3).length}
${md2}`
  } catch (e) {
    hilog.error(0, 'mdebug', `${e}`)
  }
}
