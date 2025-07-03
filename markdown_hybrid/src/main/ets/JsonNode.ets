/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { CustomLib } from 'commonmark_interop_api.so';
import { requireCJLib } from 'libark_interop_loader.so';
import collections from '@arkts.collections';
import { ArkTSUtils, JSON, lang } from '@kit.ArkTS'

export const cjLib: CustomLib = requireCJLib("libmarkdown_hybrid.so") as CustomLib

export interface JsonNodeLike {
  /* node info */
  nodeType: string
  toStr: string
  /* node tree */
  children: collections.Array<JsonNode> | undefined
  /* node attr */
  literal: string | undefined
  destination: string | undefined
  title: string | undefined
  label: string | undefined
  delimiter: string | undefined
  fenceChar: string | undefined
  fenceLength: number | undefined
  fenceIndent: number | undefined
  level: number | undefined
  bulletMarker: string | undefined
  startNumber: number | undefined
  info: string | undefined
  tight: boolean | undefined
  header: boolean | undefined
  alignment: string | undefined
  props: collections.Map<string, string> | undefined // 用于存放Js行内自定义解析插件所产生的数据
  isdone: boolean | undefined
  latex: string | undefined
  isClosed: boolean | undefined
  noteid: string | undefined
  blockIndex: number | undefined
  headIndex: number | undefined
}

@Sendable
export class JsonNode implements JsonNodeLike {
  /* node info */
  nodeType: string = ""
  toStr: string = ""
  /* node tree */
  children: collections.Array<JsonNode> | undefined = undefined
  /* node attr */
  literal: string | undefined = undefined
  destination: string | undefined = undefined
  title: string | undefined = undefined
  label: string | undefined = undefined
  delimiter: string | undefined = undefined
  fenceChar: string | undefined = undefined
  fenceLength: number | undefined = undefined
  fenceIndent: number | undefined = undefined
  level: number | undefined = undefined
  bulletMarker: string | undefined = undefined
  startNumber: number | undefined = undefined
  info: string | undefined = undefined
  tight: boolean | undefined = undefined
  header: boolean | undefined = undefined
  alignment: string | undefined = undefined
  props: collections.Map<string, string> | undefined = undefined // 用于存放Js行内自定义解析插件所产生的数据
  isdone: boolean | undefined = undefined
  latex: string | undefined = undefined
  isClosed: boolean | undefined = undefined
  noteid: string | undefined = undefined
  blockIndex: number | undefined = undefined
  headIndex: number | undefined = undefined

  constructor(data: JsonNodeLike) {
    this.nodeType = data.nodeType
    this.toStr = data.toStr
    this.children = data.children
    this.literal = data.literal
    this.destination = data.destination
    this.title = data.title
    this.label = data.label
    this.delimiter = data.delimiter
    this.fenceChar = data.fenceChar
    this.fenceLength = data.fenceLength
    this.fenceIndent = data.fenceIndent
    this.level = data.level
    this.bulletMarker = data.bulletMarker
    this.startNumber = data.startNumber
    this.info = data.info
    this.tight = data.tight
    this.header = data.header
    this.alignment = data.alignment
    this.props = data.props
    this.isdone = data.isdone
    this.latex = data.latex
    this.isClosed = data.isClosed
    this.noteid = data.noteid
    this.blockIndex = data.blockIndex
    this.headIndex = data.headIndex
  }
}

export function json2Node(jsonStr: string): JsonNode {
  let container = JSON.parse(jsonStr, (key, value) => {
    switch (key) {
      case 'children':
        let originArray = value as Array<JsonNode>
        let children = collections.Array.from<JsonNode>(originArray)
        return children
      case 'props':
        let propsMap = value as Map<string, string>
        let props = new collections.Map<string, string>(propsMap)
        return props
      default:
        if (Number(key) >= 0) {
          return new JsonNode(value as JsonNodeLike)
        }
        return value
    }
  }) as JsonNode
  return container
}


export function printJsonNode(node: JsonNode): string {
  let builder = Array<string>()
  printNodeDep(node, 0, builder)
  return builder.join('')
}

function printNodeDep(node: JsonNode | undefined, dep: number, builder: Array<string>) {
  if (node) {
    let str = node.toStr
    builder.push(`${' '.repeat(dep)}${str}\n`)
    node.children?.map((child) => {
      printNodeDep(child, dep + 4, builder)
    })
  }
}
