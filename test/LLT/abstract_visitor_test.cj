// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

main(): Int64 {
    let tester = AbstractVisitorTest()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
}

class AbstractVisitorImpl <: AbstractVisitor {
    public func visit(text: Text): Unit {
        text.insertAfter(Code(text.getLiteral()))
        text.unlink()
    }
}

@Test
public class AbstractVisitorTest {
    @TestCase
    public func replacingNodeInVisitorShouldNotDestroyVisitOrder(): Unit {
        let visitor: Visitor = AbstractVisitorImpl()

        let paragraph: Paragraph = Paragraph()
        paragraph.appendChild(Text("foo"))
        paragraph.appendChild(Text("bar"))

        paragraph.accept(visitor)

        assertCode("foo", paragraph.getFirstChild()())
        assertCode("bar", paragraph.getFirstChild()().getNext()())
        assertNull(paragraph.getFirstChild()().getNext()().getNext())
        assertCode("bar", paragraph.getLastChild()())
    }

    private static func assertCode(expectedLiteral: String, node: Node): Unit {
        // println("${"Code"} ${node.getNodeType()}")
        // println("${"Code" == node.getNodeType()}")
        assertEquals("Expected node to be a Code node: ${node}", "Code", node.getNodeType())
        let code: Code = (node as Code).getOrThrow()
        assertEquals(expectedLiteral, code.getLiteral())
    }
}
