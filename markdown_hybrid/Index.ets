/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { InlineContentParser } from "./src/main/ets/InlineContentParser"
import { JsNode } from "./src/main/ets/JsNode"
import { json2Node, JsonNode } from "./src/main/ets/JsonNode";
import { parseIntoJsNode as cj_parseIntoJsNode, parse2Json as cj_parse2Json } from 'libmarkdown_hybrid.so'


export { JsNode, printNode } from './src/main/ets/JsNode'

export { JsonNode, printJsonNode } from './src/main/ets/JsonNode'

export { InlineContentParser, Scanner, JsInlineCustomNode, ParsedInline } from './src/main/ets/InlineContentParser'

@Concurrent
export async function parseIntoJsNode(md: string, ...customParsers: Array<InlineContentParser>): Promise<JsNode> {
  return cj_parseIntoJsNode(md, JsNode, customParsers) as JsNode
}

@Concurrent
export async function parse2Json(md: string, ...customParsers: Array<InlineContentParser>): Promise<JsonNode> {
  let res = cj_parse2Json(md, JsNode, customParsers)
  return json2Node(res)
}