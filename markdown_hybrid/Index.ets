/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { hilog } from "@kit.PerformanceAnalysisKit";
import { InlineContentParser } from "./src/main/ets/InlineContentParser"
import { JsNode } from "./src/main/ets/JsNode"
import { cjLib } from "./src/main/ets/interop_api"

export { JsNode, printNode } from './src/main/ets/JsNode'

export { InlineContentParser,
  Scanner,
  JsInlineCustomNode,
  ParsedInline,
  utf8Index2utf16Index,
  utf16Index2utf8Index } from './src/main/ets/InlineContentParser'

export { cjLib, HybridParser } from './src/main/ets/interop_api'

export async function parseIntoJsNode(md: string, ...customParsers: Array<InlineContentParser>): Promise<JsNode> {
  try {
    let res = cjLib.parseIntoJsNode(md, () => new JsNode(), ...customParsers) as Promise<JsNode>
    return res
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