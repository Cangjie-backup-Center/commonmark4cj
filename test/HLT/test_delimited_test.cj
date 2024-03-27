// 3rd_party_lib:commonmark4cj/build/release/commonmark4cj
// 3rd_party_lib_ohos:commonmark4cj/build/aarch64-linux-ohos/commonmark4cj
// dependence: z_test.cj

from commonmark4cj import commonmark.*
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import reflect.{TypeInfo}



class DelimitedAbstractVisitor <: AbstractVisitor {
    var list: ArrayList<Delimited> = ArrayList<Delimited>()

    init(list: ArrayList<Delimited>) {
        this.list = list
    }
    public override func visit(node: Emphasis) {
        list.append(node)
    }
    public override func visit(node: StrongEmphasis) {
        list.append(node)
    }
}

@Test
public class DelimitedTest {
    @TestCase
    public func emphasisDelimiters(): Unit {
        let input: String = "* *emphasis* \n" + "* **strong** \n" + "* _important_ \n" + "* __CRITICAL__ \n"
        let parser: Parser = Parser.builder().build()
        let document: Node = parser.parse(input)
        let list: ArrayList<Delimited> = ArrayList<Delimited>()
        let visitor: DelimitedAbstractVisitor = DelimitedAbstractVisitor(list)
        document.accept(visitor)
        assertEquals(4, list.size)
        let emphasis: Delimited = list.get(0)()
        let strong: Delimited = list.get(1)()
        let important: Delimited = list.get(2)()
        let critical: Delimited = list.get(3)()
        assertEquals("*", emphasis.getOpeningDelimiter()())
        assertEquals("*", emphasis.getClosingDelimiter()())
        assertEquals("**", strong.getOpeningDelimiter()())
        assertEquals("**", strong.getClosingDelimiter()())
        assertEquals("_", important.getOpeningDelimiter()())
        assertEquals("_", important.getClosingDelimiter()())
        assertEquals("__", critical.getOpeningDelimiter()())
        assertEquals("__", critical.getClosingDelimiter()())
    }
}
