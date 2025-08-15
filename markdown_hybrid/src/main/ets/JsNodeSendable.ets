/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { JsNode } from './JsNode';
import collections from '@arkts.collections';

@Sendable
export class JsNodeSendableImpl implements JsNode {
  constructor() {
  }

  /* node info */
  nodeType: string = ""
  toStr: string = ""
  /* node tree */
  parent: JsNodeSendableImpl | undefined = undefined
  firstChild: JsNodeSendableImpl | undefined = undefined
  lastChild: JsNodeSendableImpl | undefined = undefined
  prev: JsNodeSendableImpl | undefined = undefined
  next: JsNodeSendableImpl | undefined = undefined
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

  getNext(): JsNodeSendableImpl | undefined {
    return this.next
  }

  getPrevious(): JsNodeSendableImpl | undefined {
    return this.prev
  }

  getFirstChild(): JsNodeSendableImpl | undefined {
    return this.firstChild
  }

  getLastChild(): JsNodeSendableImpl | undefined {
    return this.lastChild
  }

  getParent(): JsNodeSendableImpl | undefined {
    return this.parent
  }

  setParent(parent: JsNodeSendableImpl | undefined) {
    this.parent = parent
  }

  setPrevious(prev: JsNodeSendableImpl | undefined) {
    this.prev = prev
  }

  setNext(next: JsNodeSendableImpl | undefined) {
    this.next = next
  }

  setFirstChild(firstChild: JsNodeSendableImpl | undefined) {
    this.firstChild = firstChild
  }

  setLastChild(lastChild: JsNodeSendableImpl | undefined) {
    this.lastChild = lastChild
  }

  appendChild(child: JsNodeSendableImpl) {
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

  prependChild(child: JsNodeSendableImpl) {
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

  insertAfter(sibling: JsNodeSendableImpl) {
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

  insertBefore(sibling: JsNodeSendableImpl) {
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
