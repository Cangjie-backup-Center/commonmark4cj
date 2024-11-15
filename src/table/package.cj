/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */

/**
 * commonmark extension for GFM strikethrough using ~~ (GitHub Flavored Markdown)
 */
package commonmark4cj.table

internal import commonmark4cj.commonmark.*
internal import std.collection.{HashSet, HashMap, Map, ArrayList}

extend<T> Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}

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