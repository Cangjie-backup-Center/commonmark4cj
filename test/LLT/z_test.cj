from commonmark4cj import commonmark.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import reflect.*
from std import collection.*
from std import fs.*

func assertEquals<T>(msg: String, expected: T, actual: T): Unit where T <: Equatable<T> {
    if (expected != actual) {
        throw Exception(msg)
    }
}
func assertEquals<T>(expected: T, actual: T): Unit where T <: Equatable<T> {
    @PowerAssert(expected == actual)
}
func assertNull<T>(any: ?T): Unit {
    if (any.isSome()) {
        throw Exception("expected null, but was:Some()")
    }
}
extend Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}
public class TestResources {
    public static func getSpec(): Path {
        return Path("/spec.txt")
    }

    public static func getRegressions(): Array<Path> {
        return [Path("/cmark-regression.txt"), Path("/commonmark.js-regression.txt")]
    }

    public static func readAsString(url: Path): String {
        return String.fromUtf8(File.readFrom(url))
    }
}

func printNode(node: ?Node): Unit {
    if (let Some(v) <- node) {
        var current = v
        while (let Some(p) <- (current.getParent())) {
            current = p
        }
        printNode(current, 0)
    }
}

func printNode(node: ?Node, dep: Int): Unit {
    if (node.isNone()) {
        return
    }
    println("${" "*dep}${node}")
    let child = node?.getFirstChild() ?? None
    printNode(child, dep + 4)
    let next = node?.getNext() ?? None
    printNode(next, dep)
}
