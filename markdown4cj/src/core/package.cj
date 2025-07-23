/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.core

internal import commonmark4cj.commonmark.*
internal import std.collection.ArrayList
internal import std.collection.HashMap
internal import std.collection.HashSet
internal import std.collection.Map
internal import std.collection.collectArrayList
internal import std.collection.collectString
internal import std.collection.map
internal import std.collection.forEach
internal import std.time.DateTime
internal import std.regex.Matcher
internal import std.regex.Regex

/**
 * 扩展Option，getOrThrow()方法直接用()
 */
extend<T> Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}

/**
 * 扩展Option，实现Option类型直接使用==和!=
 */
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

public type Runnable = () -> Unit

extend StringBuilder {
    func appends(str: ToString): StringBuilder {
        this.append(str)
        return this
    }
}
