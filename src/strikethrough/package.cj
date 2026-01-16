/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

/**
 * commonmark extension for GFM strikethrough using ~~ (GitHub Flavored Markdown)
 */
package cangjie_tpc::commonmark4cj.strikethrough

internal import cangjie_tpc::commonmark4cj.commonmark.*
internal import std.collection.{HashSet, HashMap, Map}

extend<T> Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}
