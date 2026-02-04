/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { JsNode } from "./src/main/ets/JsNode"
import { JsNodeSendableImpl } from "./src/main/ets/JsNodeSendable";
import { InlineContentParser } from "./src/main/ets/InlineContentParser"
import { cjLib } from "./src/main/ets/interop_api"
import { hilog } from "@kit.PerformanceAnalysisKit";
import { Options } from "./src/main/ets/Options";

export { JsNode, SourceSpan, printNode } from './src/main/ets/JsNode'

export { JsNodeImpl } from './src/main/ets/JsNodeImpl'

export { JsNodeSendableImpl } from './src/main/ets/JsNodeSendable'

export { InlineContentParser,
  Scanner,
  JsInlineCustomNode,
  ParsedInline,
  utf8Index2utf16Index,
  utf16Index2utf8Index } from './src/main/ets/InlineContentParser'

export { Options } from './src/main/ets/Options'

export { cjLib, HybridParser } from './src/main/ets/interop_api'

/**
 * parseIntoJsNode
 * @param md: markdown文本
 * @param opt: markdown options
 * @returns Promise<JsNode>
 */
export async function parseIntoJsNode(md: string, opt: Options): Promise<JsNode> {
  try {
    let res = cjLib.parseIntoJsNode(md, opt) as Promise<JsNode>
    return res
  } catch (e) {
    hilog.error(0, 'mdebug', `cj parseIntoJsNode error: ${e} \n ${e.stack}`)
    throw new Error(`cj parseIntoJsNode error: ${e}`)
  }
}

// export async function parse2Json(md: string, ...customParsers: Array<InlineContentParser>): Promise<JsonNode> {
//   // let cjLib: CustomLib = requireCJLib("libcommonmark_hybrid.so") as CustomLib
//   let res = await cjLib.parse2Json(md, JsNode, customParsers)
//   return json2Node(res)
// }

export  function splitTextToArr(reg: string, text: string): string[] {
  return cjLib.splitTextToArr(reg, text)
}