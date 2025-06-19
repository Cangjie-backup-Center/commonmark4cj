/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
package markdown.plugin

abstract class AppendableUtils {
    static func appendQuietly(appendable: Appendable, c: Rune): Unit {
        appendable.append(c)
    }

    static func appendQuietly(appendable: Appendable, cs: String): Unit {
        appendable.append(cs)
    }

    static func appendQuietly(appendable: Appendable, cs: String, start: Int, end: Int): Unit {
        appendable.append(cs[start..end])
    }
}
