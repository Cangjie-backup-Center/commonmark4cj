// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

from commonmark4cj import commonmark.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import collection.*

main(): Int64 {
    let tester = BlockNodeTest()
    tester.documentTest()
    tester.documentTest2()
    tester.indentedCodeBlockTest()
    tester.fencedCodeBlockTest()
    tester.headingTest()
    tester.bulletListTest()
    tester.orderedListTest()
    0
}
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
        var text = Text("text")

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
