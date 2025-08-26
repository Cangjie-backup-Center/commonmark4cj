/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { SourceType } from "@kit.InputKit"

export interface JsNode {
  getNext(): JsNode | undefined

  getPrevious(): JsNode | undefined

  getFirstChild(): JsNode | undefined

  getLastChild(): JsNode | undefined

  getParent(): JsNode | undefined

  setParent(parent: JsNode | undefined): void

  setPrevious(prev: JsNode | undefined): void

  setNext(next: JsNode | undefined): void

  setFirstChild(firstChild: JsNode | undefined): void

  setLastChild(lastChild: JsNode | undefined): void

  appendChild(child: JsNode): void

  prependChild(child: JsNode): void

  unlink(): void

  insertAfter(sibling: JsNode): void

  insertBefore(sibling: JsNode): void

  toString(): string

  getNodeType(): string

  getLiteral(): string | undefined

  getDestination(): string | undefined

  getTitle(): string | undefined

  getLabel(): string | undefined

  getOpeningDelimiter(): string | undefined

  getClosingDelimiter(): string | undefined

  getFenceChar(): string | undefined

  getFenceLength(): number | undefined

  getFenceIndent(): number | undefined

  getInfo(): string | undefined

  isTight(): boolean | undefined

  getBulletMarker(): string | undefined

  getStartNumber(): number | undefined

  getDelimiter(): string | undefined

  putProp(k: string, v: string): void

  /*
   * 获取SourceSpan信息
   */
  getSourceSpans(): Array<SourceSpan>

  /*
   * 添加SourceSpan信息
   */
  addSourceSpans(...numbers: Array<number>): void

  /*
   * 重置Node 以供复用
   */
  reset(): void
}

export interface SourceSpan {
  /*
   * 行号
   */
  getLineIndex(): number

  /*
   * 列号
   */
  getColumnIndex(): number

  /*
   * 全文起始下标(utf8)
   */
  getInputIndex(): number

  /*
   * 长度
   */
  getLength(): number
}

export function printNode(node: JsNode): string {
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
    let str = node.toString()
    let sss = node.getSourceSpans().map((v)=>JSON.stringify(v)).join(',')
    let sssize = node.getSourceSpans().length
    builder.push(`${' '.repeat(dep)}${str}${sssize}:[${sss}]\n`)
    let child = node.getFirstChild()
    printNodeDep(child, dep + 4, builder)
    let next = node.getNext()
    printNodeDep(next, dep, builder)
  }
}
