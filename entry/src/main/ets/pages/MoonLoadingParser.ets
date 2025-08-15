/**
 * @desc   : 小月球loading 解析器
 * @author : guoxiao@moonshot.cn
 * @date   : 2025/7/1 20:29
 */
import { InlineContentParser, ParsedInline, Scanner,
  utf16Index2utf8Index,
  utf8Index2utf16Index } from './md';

export class MoonLoadingParser implements InlineContentParser {
  static MOON_LOADING = '<^moonLoading^>'

  getTriggerCharacters(): string[] {
    return ['<'];
  }

  tryParse(scanner: Scanner): ParsedInline | undefined {
    let line = scanner.lines[scanner.lineIndex]
    let start = utf8Index2utf16Index(line, scanner.index)
    let str = line.substring(start)
    if (str.startsWith(MoonLoadingParser.MOON_LOADING)) {
      return {
        node: {
          nodeType: 'NodeType.Moon',
          props: new Map()
        },
        index: utf16Index2utf8Index(line, start + MoonLoadingParser.MOON_LOADING.length),
        lineIndex: scanner.lineIndex
      }
    } else {
      return undefined
    }
  }
}