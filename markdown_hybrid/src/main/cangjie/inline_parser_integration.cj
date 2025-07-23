/**
 * Created on 022 25/7/22
 */
package markdown_hybrid

interface InlineParserIntegration <: InlineContentParser & InlineContentParserFactory {}

class Plugin4InlineParserIntegration <: AbstractMarkdownPlugin {
    Plugin4InlineParserIntegration(let arr: Collection<InlineParserIntegration>) {}
    public func configureParser(parserBuilder: ParserBuilder): Unit {
        for (f in arr) {
            parserBuilder.customInlineContentParserFactory(f)
        }
    }
    public func getClassType(): String {
        'Plugin4InlineParserIntegration'
    }
}
