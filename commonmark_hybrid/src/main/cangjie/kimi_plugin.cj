/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package commonmark_hybrid

class KimiPlugin <: AbstractMarkdownPlugin {
    KimiPlugin() {
        /* delimiter run 只判断ascii标点 */
        Characters.isPunctuationCodePoint = {
            codePoint: Rune =>
            /*
             * An ASCII punctuation character is
             * !, ", #, $, %, &, ', (, ), *, +, ,, -, ., / (U+0021–2F)
             * :, ;, <, =, >, ?, @ (U+003A–0040)
             * [, \, ], ^, _, ` (U+005B–0060)
             * {, |, }, or ~ (U+007B–007E)
             */
            match {
                case r'!' <= codePoint && codePoint <= r'.' => return true
                case r':' <= codePoint && codePoint <= r'@' => return true
                case r'[' <= codePoint && codePoint <= r'`' => return true
                case r'{' <= codePoint && codePoint <= r'~' => return true
                case _ => return false
            }
        }
    }
    public func getClassType(): String {
        'KimiPlugin'
    }
}
