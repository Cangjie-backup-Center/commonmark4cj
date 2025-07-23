/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { /*parse2Json,*/ /*printJsonNode,*/ } from '@cangjie-tpc/markdown_hybrid';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';

export async function sample_parse2Json_bench(spec: string, msg: (m: string) => void): Promise<void> {
  // let i = 0
  // let tid = setInterval(() => {
  //   if (i % 100 == 0) {
  //     hilog.error(0, 'mdebug', `i:${i}`)
  //   }
  //   parse2Json(spec).then(node => {
  //     msg(`parse2Json bench doing`);
  //   })
  //   i += 1
  //   if (i >= spec.length) {
  //     clearInterval(tid)
  //   }
  // }, 30)
}
