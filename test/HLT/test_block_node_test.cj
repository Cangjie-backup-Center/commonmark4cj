// 3rd_party_lib:commonmark4cj/build/release/commonmark4cj
// 3rd_party_lib_ohos:commonmark4cj/build/aarch64-linux-ohos/commonmark4cj
// dependence: z_test.cj

from commonmark4cj import commonmark.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import collection.*

@Test
public class BlockNodeTest {
    @TestCase
    func documentTest(): Unit {
        var document: Document = Document ()
        var paragraph = Paragraph()
        var blockQuote = BlockQuote()
        var htmlBlock = HtmlBlock()
        var thematicBreak = ThematicBreak()
        var indentedCodeBlock = IndentedCodeBlock()
        var text = Text("text")
        document.appendChild(paragraph)
        document.appendChild(blockQuote)
        document.appendChild(htmlBlock)
        document.appendChild(thematicBreak)
        document.appendChild(indentedCodeBlock)
        document.appendChild(text)
        assertEquals("Document{}", blockQuote.getParent()().toString())
        assertEquals(None, document.getParent())
        htmlBlock.setLiteral("p1")
        assertEquals("p1", htmlBlock.getLiteral())
        assertEquals("HtmlBlock{}", thematicBreak.getPrevious()().toString())
        htmlBlock.insertBefore(Text("foo"))
        assertEquals("Text{literal=foo}", htmlBlock.getPrevious()().toString())
        assertEquals(true, paragraph != htmlBlock)
    }

    @TestCase
    func documentTest2(): Unit {
        var document: Document = Document ()
        var paragraph = Paragraph()
        document.prependChild(paragraph)
        assertEquals("Paragraph{}", document.getFirstChild()().toString())
    }

    @TestCase
    func documentTest3(): Unit {
        var indentedCodeBlock  = IndentedCodeBlock()
        indentedCodeBlock.setLiteral("foo")
        assertEquals("foo", indentedCodeBlock.getLiteral())
    }

    @TestCase
    func indentedCodeBlockTest(): Unit {
        var indentedCodeBlock  = IndentedCodeBlock()
        indentedCodeBlock.setLiteral("foo")
        assertEquals("foo", indentedCodeBlock.getLiteral())
    }

    @TestCase
    func fencedCodeBlockTest(): Unit {
        var fencedCodeBlock = FencedCodeBlock()
        fencedCodeBlock.setFenceChar('`')
        fencedCodeBlock.setFenceLength(1)
        fencedCodeBlock.setFenceIndent(1)
        fencedCodeBlock.setInfo("cangjie")
        fencedCodeBlock.setLiteral("var")
        assertEquals('`', fencedCodeBlock.getFenceChar())
        assertEquals(1, fencedCodeBlock.getFenceLength())
        assertEquals(1, fencedCodeBlock.getFenceIndent())
        assertEquals("cangjie", fencedCodeBlock.getInfo())
        assertEquals("var", fencedCodeBlock.getLiteral())
    }

    @TestCase
    func headingTest(): Unit {
        var Heading = Heading ()
        Heading.setLevel(1)
        assertEquals(1, Heading.getLevel())
    }

    @TestCase
    func bulletListTest(): Unit {
        var BulletList  = BulletList('*')
        assertEquals('*', BulletList.getBulletMarker())
        BulletList.setBulletMarker('$')
        assertEquals('$', BulletList.getBulletMarker())
    }

    @TestCase
    func orderedListTest(): Unit {
        var orderedList = OrderedList(1, '.')
        assertEquals(1, orderedList.getStartNumber())
        assertEquals('.', orderedList.getDelimiter())
        orderedList.setStartNumber(2)
        orderedList.setDelimiter(',')
        assertEquals(2, orderedList.getStartNumber())
        assertEquals(',', orderedList.getDelimiter())
    }
}
