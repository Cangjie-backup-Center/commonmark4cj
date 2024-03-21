// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

from commonmark4cj import commonmark.*
from std import unittest.*
from std import unittest.testmacro.*

main(): Int64 {
    let tester = I98VRUTester()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
}

@Test
public class I98VRUTester {
    @TestCase
    func t1(): Unit {
        let md = Parser.builder().build()
        let node = md.parse("nihao仓颉")
        printNode(node)

        let text = TextContentRenderer.builder().build().render(node)
        @Assert(text,"nihao仓颉")
    }
}