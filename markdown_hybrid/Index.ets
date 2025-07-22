/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { InlineContentParser } from "./src/main/ets/InlineContentParser"
import { cjLib, JsNode } from "./src/main/ets/JsNode"

import { json2Node, JsonNode } from "./src/main/ets/JsonNode";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { CustomLib } from "commonmark_interop_api.so";
import { requireCJLib } from "libark_interop_loader.so";

// 导入仓颉运行时启动器和加载器，该名称为默认，不可以更改
export { requireCJLib } from "libark_interop_loader.so"

// 导入在ArkTS侧对于仓颉接口的映射，该名称可在ark_interop_api下的oh_package.json5中更改
export { CustomLib } from "commonmark_interop_api.so"

export { JsNode, printNode } from './src/main/ets/JsNode'

export { JsonNode, printJsonNode } from './src/main/ets/JsonNode'

export { InlineContentParser,
  Scanner,
  JsInlineCustomNode,
  ParsedInline,
  utf8Index2utf16Index,
  utf16Index2utf8Index } from './src/main/ets/InlineContentParser'

export async function parseIntoJsNode(md: string, ...customParsers: Array<InlineContentParser>): Promise<JsNode> {
  // let cjLib: CustomLib = requireCJLib("libmarkdown_hybrid.so") as CustomLib
  try {
    let res0 = cjLib.parseIntoJsNode(md, () => new JsNode(), customParsers)
    let res1 = res0 as JsNode
    return res1
  } catch (e) {
    hilog.error(0, 'mdebug', `cj parseIntoJsNode error: ${e}\n cjLib=${typeof cjLib} \n ${e.stack}`)
    throw new Error(`cj parseIntoJsNode error: ${e}`)
  }
}

export async function parse2Json(md: string, ...customParsers: Array<InlineContentParser>): Promise<JsonNode> {
  // let cjLib: CustomLib = requireCJLib("libmarkdown_hybrid.so") as CustomLib
  let res = cjLib.parse2Json(md, JsNode, customParsers)
  return json2Node(res)
}