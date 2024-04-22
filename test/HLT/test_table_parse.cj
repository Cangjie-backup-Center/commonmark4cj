// 3rd_party_lib:commonmark4cj/build/release/commonmark4cj
// 3rd_party_lib_ohos:commonmark4cj/build/aarch64-linux-ohos/commonmark4cj

from commonmark4cj import commonmark.*
from commonmark4cj import strikethrough.*
from commonmark4cj import table.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import collection.*
from std import reflect.{TypeInfo}
from std import unicode.*
from std import fs.*

@Test
public class TestTableParser {
    @TestCase
    func test_table_parser(): Unit {
        let text = htmlRender("Abc|Def")
        @Assert("<p>Abc|Def</p>\n", text)
    }

    @TestCase
    func test_table_parser2(): Unit {
        let text = textContentRender("Abc|Def\n---|---")
        @Assert("Abc| Def\n", text)
    }

    @TestCase
    func test_table_parser3(): Unit {
        let text = htmlRender("")
        @Assert("", text)
    }

    @TestCase
    func test_table_parser4(): Unit {
        let text = htmlRender(" ")
        @Assert("", text)
    }

    @TestCase
    public func testState(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse("[")
        var state: State = parser.getState()
        @Assert(getStateString(state), "lable")
    }

    @TestCase
    func test_table_parser5(): Unit {
        let text = textContentRender("")
        @Assert("", text)
    }

    @TestCase
    func test_table_parser6(): Unit {
        let text = textContentRender(" ")
        @Assert("", text)
    }

    @TestCase
    func test_strikethrough_init1(): Unit {
        var tableCell = TableCell()
        @Assert(tableCell.isHeader(), false)
        tableCell.setHeader(false)
        @Assert(tableCell.isHeader(), false)
        tableCell.setHeader(true)
        @Assert(tableCell.isHeader(), true)

        @Assert(tableCell.getAlignment().isNone(), true)
        tableCell.setAlignment(Alignment.LEFT)
        @Assert(getAlignValue(tableCell.getAlignment().getOrThrow()), "left")
        tableCell.setAlignment(Alignment.RIGHT)
        @Assert(getAlignValue(tableCell.getAlignment().getOrThrow()), "right")
    }
}

func getAlignValue(alignment: Alignment): String {
    match (alignment) {
        case LEFT => return "left"
        case CENTER => return "center"
        case RIGHT => return "right"
    }
}

func getStateString(state: State): String {
    match (state) {
        case LABEL => return "lable"
        case _ => return "else"
    }
}

func htmlRender(source: String): String {
    let EXTENSIONS: Array<Extension> = Array<Extension>([TablesExtension.create()])
    let PARSER: Parser = Parser.builder().extensions(EXTENSIONS).build()
    let RENDERER: HtmlRenderer = HtmlRenderer.builder().extensions(EXTENSIONS).build()
    return RENDERER.render(PARSER.parse(source))
}

func textContentRender(source: String): String {
    let EXTENSIONS: Array<Extension> = Array<Extension>([TablesExtension.create()])
    let PARSER: Parser = Parser.builder().extensions(EXTENSIONS).build()
    let RENDERER: TextContentRenderer = TextContentRenderer.builder().extensions(EXTENSIONS).build()
    return RENDERER.render(PARSER.parse(source))
}
