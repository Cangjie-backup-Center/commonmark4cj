/**
 * Created on 022 25/7/22
 */
package commonmark_hybrid

const TAG = 'InsertImageParser'
// 解析 <INSERT_IMAGE id="123456" /> 标签
class InsertImageParser <: InlineParserIntegration {
    static let PARAM_KEY = "key";

    private static let TAG_START = '<INSERT_IMAGE'
    private static let TAG_END = '>'

    public func create(): InlineContentParser {
        this
    }
    public func getTriggerCharacters(): HashSet<Rune> {
        return HashSet([r"<"]);
    }

    public func tryParse(inlineParserState: InlineParserState): ParsedInline {
        let scanner = inlineParserState.getScanner()
        let start = scanner.index
        let line = scanner.lines[scanner.lineIndex].getContent()
        var str = line[scanner.index..]
        if (str.startsWith(InsertImageParser.TAG_START)) {
            let endIndex = str.indexOf(InsertImageParser.TAG_END) ?? return ParsedInline.none()
            str = str[0..endIndex + 1]
            let firstQuote = str.indexOf('"') ?? return ParsedInline.none()
            let lastQuote = str.lastIndexOf('"') ?? return ParsedInline.none()
            let id = str[firstQuote + 1..lastQuote]
            //      KLog.debug(TAG, ()=>`str = ${str}, id = ${id}`)
            let map = HashMap<String, String>()
            map.add(InsertImageParser.PARAM_KEY, id)

            return ParsedInline.of(JsInlineNode('InsertImage', map),
                SourcePosition(scanner.lineIndex, start + endIndex + 1))
        } else {
            return ParsedInline.none()
        }
    }
}
