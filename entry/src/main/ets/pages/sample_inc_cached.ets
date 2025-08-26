/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import {
  InlineContentParser,
  JsNode,
  JsNodeSendableImpl,
  ParsedInline,
  parseIntoJsNode,
  printNode,
  Scanner
} from './md';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import { InsertImageParser } from './InsertImageParser';
import { MoonLoadingParser } from './MoonLoadingParser';
import { taskpool } from '@kit.ArkTS';
import { JsNodePoolImpl, parseIntoJsNodeCached } from './ParseIntoJsNodeCached';

export async function inc_cached(mdstr: string, page:object) {
  let doc0 = await parseIntoJsNode(mdstr, 0)
  let docstr0 = printNodeStruct(doc0)

  let nodepool = new JsNodePoolImpl(new JsNodeSendableImpl())
  let i = 0
  let tid = setInterval(async () => {
    try {
      let str = mdstr.slice(0, i)
      let doc = await parseIntoJsNodeCached(str, nodepool)
      let docstr = printNodeStruct(doc)
      nodepool = new JsNodePoolImpl(doc)
      page['message'] = docstr.length.toString()

      if(docstr.lastIndexOf('Document')>20){
        clearInterval(tid)
        hilog.error(0,'mdebug',`parseIntoJsNodeCached err txt: \n${str}`)
        hilog.error(0,'mdebug',`parseIntoJsNodeCached err again1: \n${printNodeStruct(await parseIntoJsNode(str, 0))}`)
        hilog.error(0,'mdebug',`parseIntoJsNodeCached err again2: \n${printNodeStruct(await parseIntoJsNodeCached(str,new JsNodePoolImpl(doc)))}`)
        hilog.error(0,'mdebug',`parseIntoJsNodeCached error: \n${docstr}`)
        // hilog.error(0,'mdebug',`parseIntoJsNodeCached origin: \n${docstr0}`)
      }
    } catch (e) {
      hilog.error(0, '', `${e}: ${e.stack}`)
    } finally {
      i+=1
      if (i > mdstr.length) {
        clearInterval(tid)
      }
    }
  }, 10)
}

export function printNodeStruct(node: JsNode): string {
  node = node as JsNode
  if (node) {
    let current: JsNode | undefined = node
    while (current?.getParent()) {
      current = (current as JsNode).getParent()
    }
    let builder = Array<string>()
    printNodeDep(current, 0, builder)
    return builder.join('')
  }
  return ''
}

function printNodeDep(node: JsNode | undefined, dep: number, builder: Array<string>) {
  node = node as JsNode
  if (node) {
    let str = node.getNodeType()
    builder.push(`${' '.repeat(dep)}${str}\n`)
    let child = node.getFirstChild()
    printNodeDep(child, dep + 4, builder)
    let next = node.getNext()
    printNodeDep(next, dep, builder)
  }
}