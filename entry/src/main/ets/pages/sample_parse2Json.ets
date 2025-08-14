/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { /*parse2Json,*/ /*printJsonNode,*/ } from '@cangjie-tpc/commonmark_hybrid';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';

export async function sample_parse2Json(spec: string): Promise<string> {
  // try {
  //   let t0 = systemDateTime.getTime()
  //   let node = await parse2Json(spec)
  //   let t1 = systemDateTime.getTime() - t0
  //   return `${t1} \n${printJsonNode(node)}`
  // } catch (e) {
  //   hilog.error(0, 'mdebug', `${e}`)
  //   return 'fail'
  // }
  return 'ignore'
}
