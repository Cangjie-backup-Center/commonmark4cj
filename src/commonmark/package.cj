/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights resvered.
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
internal import std.unicode.*

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

extend String{
    prop b: Byte {
        get(){
            this[0]
        }
    }
}

extend<T> ArrayList<T> {
    func add(t: T): Unit {
        append(t)
    }
    func add(all!: Collection<T>): Unit {
        appendAll(all)
    }
}

extend<K, V> HashMap<K, V> {
    func add(k: K, v: V): Unit {
        put(k, v)
    }
}

extend<K> HashSet<K> {
    func add(k: K): Unit {
        put(k)
    }
}

type CharSequence = String