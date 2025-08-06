/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { parseIntoJsNode, printNode } from '@cangjie-tpc/commonmark';
import { systemDateTime } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function sample_moon(): Promise<string> {
  try {
    let t0 = systemDateTime.getTime()
    let node = await parseIntoJsNode(md)
    let t1 = systemDateTime.getTime() - t0
    return `${t1} \n${printNode(node)}`
  } catch (e) {
    hilog.error(0, 'mdebug', `${e}`)
    return 'fail'
  }
}

const md = `留一个占位空文件，后续方便MarkdownDemoPage调试
你好你好你好😁😁😁😁<^moonLoading^>
<INSERT_IMAGE id="123456" /> aaaa

你好你好你好😁😁😁😁<^moonLoading^>`