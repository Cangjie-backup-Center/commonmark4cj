/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { InlineContentParser, ParsedInline, parseIntoJsNode, printNode, Scanner } from '@cangjie-tpc/commonmark';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';

export async function sample_oom(spec: string, msg: (m: string) => void): Promise<void> {
  let md = spec
  let i = 0
  let tid = setInterval(() => {
    if (i % 100 == 0) {
      hilog.error(0, 'mdebug', `i:${i}`)
    }
    parseIntoJsNode(md).then(node => {
      msg(`oom doing`);
    })
    i += 1
    if (i >= md.length) {
      clearInterval(tid)
    }
  }, 30)
}
