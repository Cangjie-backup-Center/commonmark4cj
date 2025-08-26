/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import {
  InlineContentParser,
  ParsedInline,
  parseIntoJsNode,
  printNode,
  Scanner,
  utf8Index2utf16Index,
  utf16Index2utf8Index
} from './md';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';

export async function sample_custom_inline_parser(): Promise<string> {
  let md = '😀我0123a56a89'
  const myParser: InlineContentParser = new MyParser()
  let t0 = systemDateTime.getTime()
  let node = await parseIntoJsNode(md, 0, myParser)
  let t1 = systemDateTime.getTime() - t0
  let nodeTreeStr = printNode(node)
  hilog.error(0, '', nodeTreeStr)
  return `${t1} \n${nodeTreeStr}`
}

class MyParser implements InlineContentParser {
  getTriggerCharacters(): Array<string> {
    return ['a']
  }

  tryParse(scanner: Scanner): undefined | ParsedInline {
    // hilog.error(0, 'mod', 'MyParser.tryParse')
    let str = ''
    let line = scanner.lines[scanner.lineIndex]
    let i = utf8Index2utf16Index(line, scanner.index) + 1
    for (; i < line.length; i++) {
      if (line[i] == 'a') {
        i++
        break
      }
      str += line[i]
    }
    let props = new Map<string, string>()
    props.set('str', str)
    return {
      node: {
        nodeType: 'anode',
        props: props
      },
      index: utf16Index2utf8Index(line, i),
      lineIndex: scanner.lineIndex
    }
  }
}
