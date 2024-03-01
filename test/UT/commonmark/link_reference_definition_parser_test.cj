package commonmark
from std import unittest.*
from std import unittest.testmacro.*

@Test
public class LinkReferenceDefinitionParserTest {

    @TestCase
    public func testStartLabel(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse("[".toRuneArray())

        @Expect(parser.getParagraphContent().toString(), "[")
    }

    @TestCase
    public func testStartNoLabel(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        assertParagraph("a")
        parser.parse("a".toRuneArray())
        parser.parse("[".toRuneArray())
        @Expect("a\n[", parser.getParagraphContent().toString())
    }

    @TestCase
    public func testEmptyLabel(): Unit {
        assertParagraph("[]: /")
        assertParagraph("[ ]: /")
        assertParagraph("[ \t\n\u{000B}\f\r ]: /")
    }

    @TestCase
    public func testLabelColon(): Unit {
        assertParagraph("[foo] : /")
    }

    @TestCase
    public func testLabel(): Unit {
        assertState("[foo]:", State.DESTINATION, "[foo]:")
        assertState("[ foo ]:", State.DESTINATION, "[ foo ]:")
    }

    @TestCase
    public func testLabelInvalid(): Unit {
        assertParagraph("[foo[]:")
    }

    @TestCase
    public func testLabelMultiline(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse("[two".toRuneArray())
        parser.parse("lines]:".toRuneArray())
        parser.parse("/url".toRuneArray())
        assertDef(parser.getDefinitions().get(0)(), "two lines", "/url", None)
    }

    @TestCase
    public func testLabelStartsWithNewline(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse("[".toRuneArray())
        parser.parse("weird]:".toRuneArray())
        parser.parse("/url".toRuneArray())
        assertDef(parser.getDefinitions().get(0)(), "weird", "/url", None)
    }

    @TestCase
    public func testDestination(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse("[foo]: /url".toRuneArray())
        @Expect("", parser.getParagraphContent().toString())

        @Expect(1, parser.getDefinitions().size)
        assertDef(parser.getDefinitions().get(0)(), "foo", "/url", None)

        parser.parse("[bar]: </url2>".toRuneArray())
        assertDef(parser.getDefinitions().get(1)(), "bar", "/url2", None)
    }

    @TestCase
    public func testDestinationInvalid(): Unit {
        assertParagraph("[foo]: <bar<>")
    }

    @TestCase
    public func testTitle(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse("[foo]: /url 'title'".toRuneArray())
        @Expect("", parser.getParagraphContent().toString())

        @Expect(1, parser.getDefinitions().size)
        assertDef(parser.getDefinitions().get(0)(), "foo", "/url", "title")
    }

    @TestCase
    public func testTitleStartWhitespace(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse("[foo]: /url".toRuneArray())
        @Expect("", parser.getParagraphContent().toString())

        parser.parse("   ".toRuneArray())

        @Expect("   ", parser.getParagraphContent().toString())

        @Expect(1, parser.getDefinitions().size)
        assertDef(parser.getDefinitions().get(0)(), "foo", "/url", None)
    }

    @TestCase
    public func testTitleMultiline(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse("[foo]: /url 'two".toRuneArray())
        @Expect("[foo]: /url 'two", parser.getParagraphContent().toString())
        @Expect(0, parser.getDefinitions().size)

        parser.parse("lines".toRuneArray())
        @Expect("[foo]: /url 'two\nlines", parser.getParagraphContent().toString())
        @Expect(0, parser.getDefinitions().size)

        parser.parse("'".toRuneArray())
        @Expect("", parser.getParagraphContent().toString())

        @Expect(1, parser.getDefinitions().size)
        assertDef(parser.getDefinitions().get(0)(), "foo", "/url", "two\nlines\n")
    }

    @TestCase
    public func testTitleMultiline2(): Unit {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse("[foo]: /url '".toRuneArray())
        parser.parse("title'".toRuneArray())

        assertDef(parser.getDefinitions().get(0)(), "foo", "/url", "\ntitle")
    }

    @TestCase
    public func testTitleInvalid(): Unit {
        assertParagraph("[foo]: /url (invalid(")
        assertParagraph("[foo]: </url>'title'")
        assertParagraph("[foo]: /url 'title' INVALID")
    }
    
    private static func assertParagraph(input: String) {
        assertState(input, State.PARAGRAPH, input)
    }

    private static func assertState(input: String, state: State, paragraphContent: String) {
        let parser: LinkReferenceDefinitionParser = LinkReferenceDefinitionParser()
        parser.parse(input.toRuneArray())
        @Expect(paragraphContent, parser.getParagraphContent().toString())
    }

    private static func assertDef(def: LinkReferenceDefinition, label: String, destination: String, title: ?String) {
        @Expect(label, def.getLabel())
        @Expect(destination, def.getDestination())
        @Expect(title, def.getTitle())
    }
}
