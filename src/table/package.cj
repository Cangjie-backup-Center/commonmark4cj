/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

/**
 * commonmark extension for GFM strikethrough using ~~ (GitHub Flavored Markdown)
 */
package commonmark4cj.table

internal import commonmark4cj.commonmark.*
internal import std.collection.{HashSet, HashMap, Map, ArrayList}
internal import std.unicode.{UnicodeExtension}

extend<T> Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}

public type CharSequence = Array<Rune>

extend Array<Rune> {
    func trim(): Array<Rune> {
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

    func replace(old: Rune, new: Rune): Unit {
        for (i in 0..this.size) {
            if (this[i] == old) {
                this[i] = new
            }
        }
    }
}
