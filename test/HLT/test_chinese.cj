// 3rd_party_lib:commonMark4cj/build/release/commonmark4cj
// 3rd_party_lib_ohos:commonmark4cj/build/aarch64-linux-ohos/commonmark4cj
from commonmark4cj import commonmark.*
from commonmark4cj import table.*
from commonmark4cj import strikethrough.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import collection.*


@Test 
public class TextContentRendererTest {

    private static let EXTENSIONS: Iterable<Extension> = ArrayList<Extension>(StrikethroughExtension.create())
    private static let PARSER: Parser = Parser.builder().extensions(EXTENSIONS).build()
    private static let HTML_RENDERER: HtmlRenderer = HtmlRenderer.builder().extensions(EXTENSIONS).build()
    private static let CONTENT_RENDERER: TextContentRenderer  = TextContentRenderer.builder().extensions(EXTENSIONS).build()
    private static let CONTENT_RENDERER1: TextContentRenderer  = TextContentRenderer.builder().build()

    @TestCase
    func TextContentRenderer01(): Unit {
        let document: Node = PARSER.parse("~~foo~~")
        @Assert("",CONTENT_RENDERER1.render(document))
    }

 
    @TestCase
    func TextContentRenderer02(): Unit {
        let document: Node = PARSER.parse("仓颉")
        @Assert("仓颉",CONTENT_RENDERER.render(document))
    }
}