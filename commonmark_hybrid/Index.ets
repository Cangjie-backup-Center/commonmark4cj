/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { JsNode } from "./src/main/ets/JsNode"
import { JsNodeSendableImpl } from "./src/main/ets/JsNodeSendable";
import { InlineContentParser } from "./src/main/ets/InlineContentParser"
import { cjLib } from "./src/main/ets/interop_api"
import { hilog } from "@kit.PerformanceAnalysisKit";

export { JsNode, SourceSpan, printNode } from './src/main/ets/JsNode'

export { JsNodeImpl } from './src/main/ets/JsNodeImpl'

export { JsNodeSendableImpl } from './src/main/ets/JsNodeSendable'

export { InlineContentParser,
  Scanner,
  JsInlineCustomNode,
  ParsedInline,
  utf8Index2utf16Index,
  utf16Index2utf8Index } from './src/main/ets/InlineContentParser'

export { cjLib, HybridParser } from './src/main/ets/interop_api'

/**
 * parseIntoJsNode
 * @param md: markdown文本
 * @param includeSourceSpans: 是否包含SourceSpan信息 0:不包含(默认) 1:仅Block节点 2:全部节点
 * @param customParsers: 自定义行内解析插件
 * @returns Promise<JsNode>
 */
export async function parseIntoJsNode(
  md: string,
  includeSourceSpans: number,
  ...customParsers: Array<InlineContentParser>
): Promise<JsNode> {
  try {
    let res =
      cjLib.parseIntoJsNode(md, () => new JsNodeSendableImpl(), includeSourceSpans, ...customParsers) as Promise<JsNode>
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