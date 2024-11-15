/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */

/**
 * Core of commonmark (implementation of CommonMark for parsing markdown and rendering to HTML)
 */
package commonmark4cj.commonmark

internal import std.collection.{ArrayList, HashMap, HashSet, Map, EquatableCollection, Set, LinkedList, map, collectString}
internal import std.convert.{Parsable}
internal import std.format.{Formatter}
internal import std.io.{StringReader, InputStream, IOException}
internal import std.os.{getEnv}
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
let EMPTY_MAP: Map<String, String> = HashMap()
let STRINGBUILDER_CAPACITY: Int64 = 256
public type CharSequence = Array<Rune>

extend Rune{
    prop b: Byte {
        get(){
            UInt8(UInt32(this))
        }
    }
}
extend Byte{
    prop b: Byte {
        get(){
            this
        }
    }
}
extend String{
    prop b: Byte {
        get(){
            this[0]
        }
    }
}