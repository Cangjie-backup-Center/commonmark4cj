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
} from '@cangjie-tpc/markdown_hybrid';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import { InsertImageParser } from './InsertImageParser';
import { MoonLoadingParser } from './MoonLoadingParser';
import { taskpool } from '@kit.ArkTS';
import { JsNodePoolImpl, parseIntoJsNodeCached } from './ParseIntoJsNodeCached';

export async function inc_cached(mdstr: string, page:object) {
  let nodepool = new JsNodePoolImpl(new JsNode())
  let i = 0
  let tid = setInterval(async () => {
    try {
      let str = mdstr.slice(0, i)
      let doc = await parseIntoJsNodeCached(str, nodepool)
      let docstr = printNode(doc)
      nodepool = new JsNodePoolImpl(doc)
      page['message'] = docstr
    } catch (e) {
      hilog.error(0, '', `${e}: ${e.stack}`)
    } finally {
      i++
      if (i > mdstr.length) {
        clearInterval(tid)
      }
    }
  }, 10)
}
