// RESOURCES: leetCode1.txt
// RESOURCES: leetCode1_java.txt
// RESOURCES: leetCode2.txt
// RESOURCES: leetCode2_java.txt
// RESOURCES: leetCode3.txt
// RESOURCES: leetCode3_java.txt
// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj -Woff unused
// EXEC: ./main

from commonmark4cj import commonmark.*
from commonmark4cj import strikethrough.*
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import fs.*
from std import reflect.{TypeInfo}

main() {
    let tester = LeetCodeTest()
    tester.leet_Test1()
    tester.leet_Test2()
    tester.leet_Test3()
    tester.tv()
    return 0
}

@Test
public class LeetCodeTest {
    
    @TestCase
    public func leet_Test1(): Unit {
        let parser: Parser = Parser.builder().extensions([StrikethroughExtension.create()]).build()
        let spec: String = String.fromUtf8(File.readFrom("leetCode1.txt"))
        let document: Node = parser.parse(spec)
        let renderer: HtmlRenderer = HtmlRenderer.builder().escapeHtml(true).build()
        let content: String = renderer.render(document)
        let spec_java: String = String.fromUtf8(File.readFrom("leetCode1_java.txt"))

        @PowerAssert(content == spec_java)
    }

    @TestCase
    public func leet_Test2(): Unit {
        let parser: Parser = Parser.builder().extensions([StrikethroughExtension.create()]).build()
        let spec: String = String.fromUtf8(File.readFrom("leetCode2.txt"))
        let document: Node = parser.parse(spec)
        let renderer: HtmlRenderer = HtmlRenderer.builder().escapeHtml(true).build()
        let content: String = renderer.render(document)
        let spec_java: String = String.fromUtf8(File.readFrom("leetCode2_java.txt"))

        @PowerAssert(content == spec_java)
    }

    @TestCase
    public func leet_Test3(): Unit {
        let parser: Parser = Parser.builder().extensions([StrikethroughExtension.create()]).build()
        let spec: String = String.fromUtf8(File.readFrom("leetCode3.txt"))
        let document: Node = parser.parse(spec)
        let renderer: HtmlRenderer = HtmlRenderer.builder().escapeHtml(true).build()
        let content: String = renderer.render(document)
        let spec_java: String = String.fromUtf8(File.readFrom("leetCode3_java.txt"))

        @PowerAssert(content == spec_java)
    }

    @TestCase
    public func tv(): Unit {
        let tv = "📺"
        @PowerAssert(tv.size == 4)
        @PowerAssert(tv.toArray() == [240, 159, 147, 186])
    }
}