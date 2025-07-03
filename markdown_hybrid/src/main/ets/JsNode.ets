/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { CustomLib } from 'commonmark_interop_api.so';
import { requireCJLib } from 'libark_interop_loader.so';
import collections from '@arkts.collections';

export const cjLib: CustomLib = requireCJLib("libmarkdown_hybrid.so") as CustomLib

@Sendable
export class JsNode {
  constructor() {
  }

  /* node info */
  nodeType: string = ""
  toStr: string = ""
  /* node tree */
  parent: JsNode | undefined = undefined
  firstChild: JsNode | undefined = undefined
  lastChild: JsNode | undefined = undefined
  prev: JsNode | undefined = undefined
  next: JsNode | undefined = undefined
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

  getNext(): JsNode | undefined {
    return this.next
  }

  getPrevious(): JsNode | undefined {
    return this.prev
  }

  getFirstChild(): JsNode | undefined {
    return this.firstChild
  }

  getLastChild(): JsNode | undefined {
    return this.lastChild
  }

  getParent(): JsNode | undefined {
    return this.parent
  }

  setParent(parent: JsNode | undefined) {
    this.parent = parent
  }

  setPrevious(prev: JsNode | undefined) {
    this.prev = prev
  }

  setNext(next: JsNode | undefined) {
    this.next = next
  }

  setFirstChild(firstChild: JsNode | undefined) {
    this.firstChild = firstChild
  }

  setLastChild(lastChild: JsNode | undefined) {
    this.lastChild = lastChild
  }

  appendChild(child: JsNode) {
    child.unlink()
    child.setParent(this)
    if (this.lastChild) {
      this.lastChild.next = child
      child.prev = this.lastChild
      this.lastChild = child
    } else {
      this.firstChild = child
      this.lastChild = child
    }
  }

  prependChild(child: JsNode) {
    child.unlink()
    child.setParent(this)
    if (this.firstChild) {
      this.firstChild.prev = child
      child.next = this.firstChild
      this.firstChild = child
    } else {
      this.firstChild = child
      this.lastChild = child
    }
  }

  unlink() {
    if (this.prev) {
      this.prev.next = this.next
    } else if (this.parent) {
      this.parent.firstChild = this.next
    }
    if (this.next) {
      this.next.prev = this.prev
    } else if (this.parent) {
      this.parent.lastChild = this.prev
    }
    this.parent = undefined
    this.next = undefined
    this.prev = undefined
  }

  insertAfter(sibling: JsNode) {
    sibling.unlink()
    sibling.next = this.next
    if (sibling.next) {
      sibling.next.prev = sibling
    }
    sibling.prev = this
    this.next = sibling
    sibling.parent = this.parent
    if (!sibling.next) {
      sibling.parent!.lastChild = sibling
    }
  }

  insertBefore(sibling: JsNode) {
    sibling.unlink()
    sibling.prev = this.prev
    if (sibling.prev) {
      sibling.prev.next = sibling
    }
    sibling.next = this
    this.prev = sibling
    sibling.parent = this.parent
    if (!sibling.prev) {
      sibling.parent!.firstChild = sibling
    }
  }

  toString(): string {
    return this.toStr
  }

  getNodeType(): string {
    return this.nodeType
  }

  getLiteral(): string | undefined {
    return this.literal
  }

  getDestination(): string | undefined {
    return this.destination
  }

  getTitle(): string | undefined {
    return this.title
  }

  getLabel(): string | undefined {
    return this.label
  }

  getOpeningDelimiter(): string | undefined {
    return this.delimiter
  }

  getClosingDelimiter(): string | undefined {
    return this.delimiter
  }

  getFenceChar(): string | undefined {
    return this.fenceChar
  }

  getFenceLength(): number | undefined {
    return this.fenceLength
  }

  getFenceIndent(): number | undefined {
    return this.fenceIndent
  }

  getInfo(): string | undefined {
    return this.info
  }

  isTight(): boolean | undefined {
    return this.tight
  }

  getBulletMarker(): string | undefined {
    return this.bulletMarker
  }

  getStartNumber(): number | undefined {
    return this.startNumber
  }

  getDelimiter(): string | undefined {
    return this.delimiter
  }

  putProp(k: string, v: string): void {
    let m = this.props ?? new collections.Map()
    m.set(k, v)
    this.props = m
  }
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
    builder.push(`${' '.repeat(dep)}${str}\n`)
    let child = node.getFirstChild()
    printNodeDep(child, dep + 4, builder)
    let next = node.getNext()
    printNodeDep(next, dep, builder)
  }
}
