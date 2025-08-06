/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import {
  InlineContentParser,
  JsNode,
  ParsedInline,
  parseIntoJsNode,
  printNode,
  Scanner
} from '@cangjie-tpc/commonmark';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import { InsertImageParser } from './InsertImageParser';
import { MoonLoadingParser } from './MoonLoadingParser';
import { taskpool } from '@kit.ArkTS';

@Concurrent
async function parseToJsNodeImpl(text: string): Promise<JsNode> {
  return await parseIntoJsNode(text, new InsertImageParser(), new MoonLoadingParser())
}

export async function parseToJsNode(text: string): Promise<JsNode> {
  return taskpool.execute(parseToJsNodeImpl, text) as Promise<JsNode>
}

export async function sample_cppcrash(markdownString: string): Promise<void> {
  let i = 0
  let tid = setInterval(() => {
    let str = markdownString.slice(0, i)
    parseToJsNode(str).then(() => {
      hilog.error(0, '', '1.1')
    }).catch(() => {
      hilog.error(0, '', '1.2')
    })
    i += 1
    if (i >= markdownString.length) {
      i = 0
    }
  }, 10)
}
