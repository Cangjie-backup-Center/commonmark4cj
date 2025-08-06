/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { JsNode } from "@cangjie-tpc/markdown_hybrid/src/main/ets/JsNode"
import { cjLib } from "@cangjie-tpc/markdown_hybrid/src/main/ets/interop_api"
import { JsNodePoolImpl } from './ParseIntoJsNodeCached';
import { hilog } from "@kit.PerformanceAnalysisKit";
import { printNodeStruct } from "./sample_inc_cached";
import { printNode } from "@cangjie-tpc/markdown_hybrid";
import { systemDateTime } from "@kit.BasicServicesKit";

export async function kimi(page: object) {
  let md: string = page['cppcrash'] as string
  let pool = new JsNodePoolImpl(new JsNode())
  let parser = new cjLib.HybridParser(() => pool.getJsNode())

  let i = 5
  let tid = setInterval(async () => {
    try {
      let str = md.slice(0, i)
      let doc = await parser.parse(str) as JsNode
      let docstr = printNode(doc)
      pool.put(doc)
      page['message'] = docstr
    } catch (e) {
      hilog.error(0, '', `${e}: ${e.stack}`)
    } finally {
      i += 5
      if (i > md.length) {
        clearInterval(tid)
      }
    }
  }, 50)
}

export async function kimi_bench1(page: object) {
  let md: string = page['cppcrash'] as string
  let pool = new JsNodePoolImpl(new JsNode())
  let parser = new cjLib.HybridParser(() => pool.getJsNode())
  let t0 = systemDateTime.getTime()
  let i = 5
  while (i < md.length) {
    try {
      let str = md.slice(0, i)
      let doc = await parser.parse(str) as JsNode
      let docstr = printNode(doc)
      pool.put(doc)
      page['message'] = docstr.length
    } catch (e) {
      hilog.error(0, '', `${e}: ${e.stack}`)
    } finally {
      i += 50
    }
  }
  let t1 = systemDateTime.getTime()
  page['message'] = `bench HybridParser: ${t1-t0}`
}
export async function kimi_bench0(page: object) {
  let md: string = page['cppcrash'] as string
  let pool = new JsNodePoolImpl(new JsNode())
  // let parser = new cjLib.HybridParser(() => pool.getJsNode())
  let t0 = systemDateTime.getTime()
  let i = 5
  while (i < md.length) {
    try {
      let str = md.slice(0, i)
      let doc = await cjLib.parseIntoJsNode(str,() => pool.getJsNode()) as JsNode
      let docstr = printNode(doc)
      pool.put(doc)
      page['message'] = docstr.length
    } catch (e) {
      hilog.error(0, '', `${e}: ${e.stack}`)
    } finally {
      i += 50
    }
  }
  let t1 = systemDateTime.getTime()
  page['message'] = `bench parse0: ${t1-t0}`
}