// 3rd_party_lib:commonMark4cj/build/release/commonmark4cj
// 3rd_party_lib_ohos:commonmark4cj/build/aarch64-linux-ohos/commonmark4cj

from commonmark4cj import commonmark.*
from commonmark4cj import table.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import collection.*
from std import reflect.{TypeInfo}
from std import unicode.*
from std import fs.*

@Test
public class TestInlinekParser{
    @TestCase
    func test_inline_parser():Unit {
        var emphasisDelimiterProcessor: EmphasisDelimiterProcessor2 = EmphasisDelimiterProcessor2()

        @Assert('-', emphasisDelimiterProcessor.getOpeningCharacter())
        @Assert('-', emphasisDelimiterProcessor.getClosingCharacter())
        @Assert(1, emphasisDelimiterProcessor.getMinLength())
    }

    @TestCase
    func test_inline_parser2():Unit {
        var emphasisDelimiterProcessor: EmphasisDelimiterProcessor3 = EmphasisDelimiterProcessor3()

        @Assert(' ', emphasisDelimiterProcessor.getOpeningCharacter())
        @Assert(' ', emphasisDelimiterProcessor.getClosingCharacter())
        @Assert(1, emphasisDelimiterProcessor.getMinLength())
    }

    @TestCase
    func test_inline_parser3():Unit {
        var emphasisDelimiterProcessor: EmphasisDelimiterProcessor4 = EmphasisDelimiterProcessor4()

        @Assert('1', emphasisDelimiterProcessor.getOpeningCharacter())
        @Assert('1', emphasisDelimiterProcessor.getClosingCharacter())
        @Assert(1, emphasisDelimiterProcessor.getMinLength())
    }

    @TestCase
    public func test_inline_parser_inlineParser(): Unit {
        let parser: Parser = Parser.builder().inlineParserFactory(fakeInlineParserFactory()).build()
        let input: String = "**bold** **bold** ~~strikethrough~~"

        @Assert(parser.parse(input).getFirstChild().getOrThrow().getFirstChild().getOrThrow().toString(), "Text{literal=text}")
    }
}

class InlineParserImpl2 <: InlineParser {
    public override func parse(input: String, node: Node): Unit {
        node.appendChild(Text("text"))
    }
}

class fakeInlineParserFactory <: InlineParserFactory {

    public override func create(inlineParserContext: InlineParserContext): InlineParser {
        return InlineParserImpl2()
    }
}

class EmphasisDelimiterProcessor2 <: EmphasisDelimiterProcessor {
    public init() {
        super('-')
    }
}

class EmphasisDelimiterProcessor3 <: EmphasisDelimiterProcessor {
    public init() {
        super(' ')
    }
}

class EmphasisDelimiterProcessor4 <: EmphasisDelimiterProcessor {
    public init() {
        super('1')
    }
}