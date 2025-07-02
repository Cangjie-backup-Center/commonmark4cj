/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
export class Scanner {
  lines: Array<string> = [] // context
  lineIndex: number // Which line we're at.
  runeIndex: number // The Rune index within the line.
  constructor(lines: Array<string>, lineIndex: number, runeIndex: number) {
    this.lines = lines
    this.lineIndex = lineIndex
    this.runeIndex = runeIndex
  }
}

export interface JsInlineCustomNode {
  nodeType: string
  props: Map<string, string>
}

export interface ParsedInline {
  node: JsInlineCustomNode // 必须设置nodeType/props 其他属性会忽略
  lineIndex: number
  runeIndex: number
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