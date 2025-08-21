/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { JsNode } from "./JsNode"

export class JsNodeImpl implements JsNode {
  constructor() {
  }

  /* node info */
  nodeType: string = ""
  toStr: string = ""
  /* node tree */
  parent: JsNodeImpl | undefined = undefined
  firstChild: JsNodeImpl | undefined = undefined
  lastChild: JsNodeImpl | undefined = undefined
  prev: JsNodeImpl | undefined = undefined
  next: JsNodeImpl | undefined = undefined
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
  props: Map<string, string> | undefined = undefined // 用于存放Js行内自定义解析插件所产生的数据
  isdone: boolean | undefined = undefined
  latex: string | undefined = undefined
  isClosed: boolean | undefined = undefined
  noteid: string | undefined = undefined
  blockIndex: number | undefined = undefined
  headIndex: number | undefined = undefined

  getNext(): JsNodeImpl | undefined {
    return this.next
  }

  getPrevious(): JsNodeImpl | undefined {
    return this.prev
  }

  getFirstChild(): JsNodeImpl | undefined {
    return this.firstChild
  }

  getLastChild(): JsNodeImpl | undefined {
    return this.lastChild
  }

  getParent(): JsNodeImpl | undefined {
    return this.parent
  }

  setParent(parent: JsNodeImpl | undefined) {
    this.parent = parent
  }

  setPrevious(prev: JsNodeImpl | undefined) {
    this.prev = prev
  }

  setNext(next: JsNodeImpl | undefined) {
    this.next = next
  }

  setFirstChild(firstChild: JsNodeImpl | undefined) {
    this.firstChild = firstChild
  }

  setLastChild(lastChild: JsNodeImpl | undefined) {
    this.lastChild = lastChild
  }

  appendChild(child: JsNodeImpl) {
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

  prependChild(child: JsNodeImpl) {
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

  insertAfter(sibling: JsNodeImpl) {
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

  insertBefore(sibling: JsNodeImpl) {
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
    let m = this.props ?? new Map<string, string>()
    m.set(k, v)
    this.props = m
  }
}
