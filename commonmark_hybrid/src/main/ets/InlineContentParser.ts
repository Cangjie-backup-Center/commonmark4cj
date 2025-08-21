/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { util } from "@kit.ArkTS"

let textDecoder = new util.TextDecoder()
let textEncoder = new util.TextEncoder()

export interface Scanner {
  lines: Array<string> // context
  lineIndex: number // Which line we're at.
  index: number // utf8字节下标
}

/**
 * 将utf16字符下标转为utf8字节下标
 * @param line
 * @param utf16Index
 * @returns utf8字节下标
 */
export function utf16Index2utf8Index(line: string, utf16Index: number): number {
  let sub = line.slice(0, utf16Index)
  let bytes = textEncoder.encodeInto(sub)
  return bytes.byteLength
}

/**
 * 将utf8字节下标转为utf16字符下标
 * @param line
 * @param utf8Index
 * @returns utf16字符下标
 */
export function utf8Index2utf16Index(line: string, utf8Index: number): number {
  let bytes = textEncoder.encodeInto(line).slice(0, utf8Index)
  let sub = textDecoder.decodeToString(bytes)
  return sub.length
}

export interface JsInlineCustomNode {
  nodeType: string
  props: Map<string, string>
}

export interface ParsedInline {
  node: JsInlineCustomNode // 必须设置nodeType/props 其他属性会忽略
  lineIndex: number // 行号
  index: number // utf8字节下标
}

export interface InlineContentParser {
  /**
   * An inline content parser needs to have a special "trigger" character which activates it.
   */
  getTriggerCharacters(): Array<string>

  /**
   * Try to parse inline content starting from the current position.
   *
   * @param scanner the current state of the inline parser
   * @return the result of parsing; can indicate that this parser is not interested, or that parsing was successful
   */
  tryParse(scanner: Scanner): undefined | ParsedInline
}