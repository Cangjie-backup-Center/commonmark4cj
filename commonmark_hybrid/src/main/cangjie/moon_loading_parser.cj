/**
 * Created on 022 25/7/22
 */
package commonmark_hybrid

/**
 * @desc   : 小月球loading 解析器
 * @author : guoxiao@moonshot.cn
 * @date   : 2025/7/1 20:29
 */
class MoonLoadingParser <: InlineParserIntegration {
    static let MOON_LOADING = '<^moonLoading^>'

    public func create(): InlineContentParser {
        this
    }
    public func getTriggerCharacters(): Set<Rune> {
        return HashSet([r'<']);
    }
    public func tryParse(inlineParserState: InlineParserState): ParsedInline {
        let scanner = inlineParserState.scanner()
        let start = scanner.index
        let line = scanner.lines[scanner.lineIndex].getContent()
        var str = line[scanner.index..]
        if (str.startsWith(MoonLoadingParser.MOON_LOADING)) {
            return ParsedInline.of(JsInlineNode('Moon', HashMap()),
                SourcePosition(scanner.lineIndex, start + MoonLoadingParser.MOON_LOADING.size))
        } else {
            return ParsedInline.none()
        }
    }
}
