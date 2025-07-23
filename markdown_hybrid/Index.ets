/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { hilog } from "@kit.PerformanceAnalysisKit";
import { InlineContentParser } from "./src/main/ets/InlineContentParser"
import { JsNode } from "./src/main/ets/JsNode"
import { cjLib } from "./src/main/ets/JsNode"

// import { CustomLib } from "commonmark_interop_api.so";
// import { requireCJLib } from "libark_interop_loader.so";
import { testCJ,parseIntoJsNode as parseIntoJsNodeInner } from 'libmarkdown_hybrid.so';

export { JsNode, printNode } from './src/main/ets/JsNode'

export { InlineContentParser,
  Scanner,
  JsInlineCustomNode,
  ParsedInline,
  utf8Index2utf16Index,
  utf16Index2utf8Index } from './src/main/ets/InlineContentParser'

export async function parseIntoJsNode(md: string, ...customParsers: Array<InlineContentParser>): Promise<JsNode> {
  try {
    let res0 = cjLib.parseIntoJsNode(md, () => new JsNode(), customParsers)
    let res1 = res0 as JsNode
    return res1
  } catch (e) {
    hilog.error(0, 'mdebug', `cj parseIntoJsNode error: ${e} \n ${e.stack}`)
    throw new Error(`cj parseIntoJsNode error: ${e}`)
  }
}

// export async function parse2Json(md: string, ...customParsers: Array<InlineContentParser>): Promise<JsonNode> {
//   // let cjLib: CustomLib = requireCJLib("libmarkdown_hybrid.so") as CustomLib
//   let res = await cjLib.parse2Json(md, JsNode, customParsers)
//   return json2Node(res)
// }