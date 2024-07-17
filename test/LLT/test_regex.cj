// RESOURCES: regex1.txt
// RESOURCES: regex1_java.txt
// RESOURCES: regex2.txt
// RESOURCES: regex2_java.txt
// RESOURCES: regex3.txt
// RESOURCES: regex3_java.txt
// RESOURCES: regex4.txt
// RESOURCES: regex4_java.txt
// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj -Woff unused
// EXEC: ./main

import commonmark4cj.commonmark.*
import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import std.collection.*
import std.fs.*
import std.regex.{Regex, Matcher, MatchData, RegexOption, Position}

main(): Int64 {
    let tester = RegexTest()
    tester.regex_Test1()
    tester.regex_Test2()
    tester.regex_Test3()
    tester.regex_Test4()
    return 0
}

@Test
public class RegexTest {
    
    @TestCase
    public func regex_Test1(): Unit {
        let source: String = String.fromUtf8(File.readFrom("regex1.txt"))
        var rendered: String = ""

        rendered = defaultRenderer().render(parse(source))

        let spec_java: String = String.fromUtf8(File.readFrom("regex1_java.txt"))
       
        assertEquals(rendered, spec_java)
    }

    @TestCase
    public func regex_Test2(): Unit {
        let source: String = String.fromUtf8(File.readFrom("regex2.txt"))
        var rendered: String = ""

        rendered = defaultRenderer().render(parse(source))

        let spec_java: String = String.fromUtf8(File.readFrom("regex2_java.txt"))

        @PowerAssert(rendered == spec_java)
    }

    @TestCase
    public func regex_Test3(): Unit {
        let source: String = String.fromUtf8(File.readFrom("regex3.txt"))
        var rendered: String = ""
        rendered = defaultRenderer().render(parse(source))

        let spec_java: String = String.fromUtf8(File.readFrom("regex3_java.txt"))

        @PowerAssert(rendered == spec_java)
    }

    @TestCase
    public func regex_Test4(): Unit {
        let source: String = String.fromUtf8(File.readFrom("regex4.txt"))
        var rendered: String = ""
        rendered = defaultRenderer().render(parse(source))

        let spec_java: String = String.fromUtf8(File.readFrom("regex4_java.txt"))

        @PowerAssert(rendered == spec_java)
    }
}

func defaultRenderer(): TextContentRenderer {
    return TextContentRenderer.builder().build()
}

func parse(source: String): Node {
    return Parser.builder().build().parse(source)
}