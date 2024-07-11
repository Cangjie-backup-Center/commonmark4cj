/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */

/**
 * Core of commonmark (implementation of CommonMark for parsing markdown and rendering to HTML)
 */
package commonmark

from std import collection.{ArrayList, HashMap, HashSet, Map, EquatableCollection, Set, LinkedList, map, collectString}
from std import convert.{Parsable}
from std import format.{Formatter}
from std import io.{StringReader, InputStream, IOException}
from std import os.{getEnv}
from std import regex.{Regex, Matcher, MatchData, RegexOption, Position}
from std import unicode.{UnicodeExtension}

extend Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}

extend Option<T> where T <: Equatable<T> {
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
let EMPTY_MAP: Map<String, String> = HashMap()
let STRINGBUILDER_CAPACITY: Int64 = 256
public type CharSequence = Array<Rune>

extend Array<T> where T <: Rune {
    func trim(): Array<T> {
        var (a, b) = (0, this.size - 1)
        while (a <= b) {
            if (this[a].isWhiteSpace()) {
                a++
            } else {
                break
            }
        }
        while (b >= a) {
            if (this[b].isWhiteSpace()) {
                b--
            } else {
                break
            }
        }
        this[a..=b]
    }

    func replace(old: T, new: T): Unit {
        for (i in 0..this.size) {
            if (this[i] == old) {
                this[i] = new
            }
        }
    }
}
