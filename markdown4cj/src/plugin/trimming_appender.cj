/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
package markdown.plugin

abstract class TrimmingAppender {
    public func append(output: Appendable, data: String): Unit

    static func create(): TrimmingAppender {
        return TrimmingAppenderImpl()
    }
}

class TrimmingAppenderImpl <: TrimmingAppender {
    public func append(_: Appendable, _: String): Unit {
        /* let startLength = output.size
        var c: Rune = r'\u{0000}'
        var previousIsWhiteSpace = false
        var i = 0
        let dataRunes = data.toRuneArray()
        let length = dataRunes.size
        while (i < length) {
            c = data[i]
            if (c.isWhiteSpace()) {
                previousIsWhiteSpace = true
                continue
            }
            if (previousIsWhiteSpace) {
                let outputLength = output.size
                if (outputLength > 0 && !output.charAt(outputLength - 1).isWhiteSpace()) {
                    AppendableUtils.appendQuietly(output, r' ')
                }
            }
            previousIsWhiteSpace = false
            AppendableUtils.appendQuietly(output, c)
        }
        if (previousIsWhiteSpace && (startLength < output.size)) {
            AppendableUtils.appendQuietly(output, r' ')
        }*/
    }
}
