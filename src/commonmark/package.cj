/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

/**
 * Core of commonmark (implementation of CommonMark for parsing markdown and rendering to HTML)
 */
package commonmark4cj.commonmark

internal import std.collection.{ArrayList, HashMap, HashSet, Map, EquatableCollection, Set, LinkedList, map, collectString, collectHashSet}
internal import std.convert.*
internal import std.io.{StringReader, InputStream, IOException}
internal import std.regex.{Regex, Matcher, MatchData, RegexOption, Position}

extend<T> Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}

extend<T> Option<T> where T <: Equatable<T> {
    operator func ==(other: T): Bool {
        match (this) {
            case Some(v) => v == other
            case _ => false
        }
    }
    operator func !=(other: T): Bool {
        match (this) {
            case Some(v) => v != other
            case _ => true
        }
    }
}

let NULL_CHAR: Rune = '\u{0}'
let EMPTY_STRING: String = ""
let EMPTY_MAP: HashMap<String, String> = HashMap()
let STRINGBUILDER_CAPACITY: Int64 = 256
public type CharSequence = Array<Rune>

extend Array<Rune> {
    func trim(): Array<Rune> {
        var (a, b) = (0, this.size - 1)
        while (a <= b) {
            if (this[a].isAsciiWhiteSpace()) {
                a++
            } else {
                break
            }
        }
        while (b >= a) {
            if (this[b].isAsciiWhiteSpace()) {
                b--
            } else {
                break
            }
        }
        this[a..=b]
    }

    func replace(old: Rune, new: Rune): Unit {
        for (i in 0..this.size) {
            if (this[i] == old) {
                this[i] = new
            }
        }
    }
}
