/**
 * @desc   :
 * @author : guoxiao@moonshot.cn
 * @date   : 2025/7/1 17:49
 */
import { InlineContentParser, ParsedInline, Scanner,
  utf16Index2utf8Index,
  utf8Index2utf16Index } from '@cangjie-tpc/markdown_hybrid';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'InsertImageParser'
// 解析 <INSERT_IMAGE id="123456" /> 标签
export class InsertImageParser implements InlineContentParser {
  static readonly PARAM_KEY = "key";

  private static readonly TAG_START = '<INSERT_IMAGE'
  private static readonly TAG_END = '>'

  getTriggerCharacters(): string[] {
    return ["<"];
  }

  tryParse(scanner: Scanner): ParsedInline | undefined {
    let line = scanner.lines[scanner.lineIndex]
    let start = utf8Index2utf16Index(line, scanner.index)
    let str = line.substring(start)
    if (str.startsWith(InsertImageParser.TAG_START)) {
      const endIndex = str.indexOf(InsertImageParser.TAG_END)
      if (endIndex === -1) {
        return undefined
      }
      str = str.substring(0 ,endIndex + 1)
      const firstQuote = str.indexOf('"')
      const lastQuote = str.lastIndexOf('"')
      const id = str.substring(firstQuote + 1, lastQuote)
      hilog.debug(0,TAG, `str = ${str}, id = ${id}`)
      const map = new Map<string, string>()
      map.set(InsertImageParser.PARAM_KEY, id)

      return {
        node: {
          nodeType: "NodeType.InsertImage",
          props: map
        } ,
        index: utf16Index2utf8Index(line, start + endIndex + 1),
        lineIndex: scanner.lineIndex
      }
    } else {
      return undefined
    }

  }
}