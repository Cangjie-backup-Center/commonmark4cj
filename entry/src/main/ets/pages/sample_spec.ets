/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { parseIntoJsNode, printNode } from '@cangjie-tpc/commonmark';
import { systemDateTime } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function sample_spec(spec: string): Promise<string> {
  try {
    let t0 = systemDateTime.getTime()
    let node = await parseIntoJsNode(spec)
    let t1 = systemDateTime.getTime() - t0
    return `${t1} \n${printNode(node)}`
  } catch (e) {
    hilog.error(0, 'mdebug', `${e}`)
    return 'fail'
  }
}