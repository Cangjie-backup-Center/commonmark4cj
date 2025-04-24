/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights resvered.
 */
package commonmark4cj.commonmark

/**
 * Functions for finding characters in strings or checking characters.
 */
public class Characters {
    public static func find(c: Byte, s: CharSequence, startIndex: Int): Int {
        let length = s.size
        for (i in startIndex..length) {
            if (s[i] == c) {
                return i
            }
        }
        return -1
    }

    public static func findLineBreak(s: CharSequence, startIndex: Int): Int {
        let length = s.size
        for (i in startIndex..length) {
            match (s[i]) {
                case b'\n' | b'\r' => return i
                case _ => ()
            }
        }
        return -1
    }

    /**
     * @see <a href="https://spec.commonmark.org/0.31.2/#blank-line">blank line</a>
     */
    public static func isBlank(s: CharSequence): Bool {
        return skipSpaceTab(s, 0, s.size) == s.size
    }

    public static func hasNonSpace(s: CharSequence): Bool {
        let length = s.size
        let skipped = skip(b' ', s, 0, length)
        return skipped != length
    }

    public static func isLetter(s: CharSequence, index: Int): Bool {
        let codePoint = Rune.fromUtf8(unsafe { s.rawData() }, index)
        return codePoint[0].isLetter()
    }

    public static func isSpaceOrTab(s: CharSequence, index: Int): Bool {
        if (index < s.size) {
            match (s[index]) {
                case b' ' | b'\t' => return true
                case _ => ()
            }
        }
        return false
    }

    /**
     * @see <a href="https://spec.commonmark.org/0.31.2/#unicode-punctuation-character">Unicode punctuation character</a>
     */
    public static func isPunctuationCodePoint(codePoint: Rune): Bool {
        // match(Character.getType(codePoint)) {
        //     case DASH_PUNCTUATION|START_PUNCTUATION|END_PUNCTUATION|CONNECTOR_PUNCTUATION|OTHER_PUNCTUATION|INITIAL_QUOTE_PUNCTUATION|FINAL_QUOTE_PUNCTUATION=>
        //         // General category "P" (punctuation)
        //         return true
        //     case MATH_SYMBOL|CURRENCY_SYMBOL|MODIFIER_SYMBOL|OTHER_SYMBOL=>
        //         // General category "S" (symbol)
        //         return true
        // }
        match (codePoint) {
            case '$' | '+' | '<' | '=' | '>' | '^' | '`' | '|' | '~' => return true
            case _ => return false
        }
    }

    /**
     * Check whether the provided code point is a Unicode whitespace character as defined in the spec.
     *
     * @see <a href="https://spec.commonmark.org/0.31.2/#unicode-whitespace-character">Unicode whitespace character</a>
     */
    public static func isWhitespaceCodePoint(codePoint: Rune): Bool {
        match (codePoint) {
            case ' ' | '\t' | '\n' | '\f' | '\r' => return true
            case _ => return codePoint.isWhiteSpace()
        }
    }

    public static func skip(skip: Byte, s: CharSequence, startIndex: Int, endIndex: Int): Int {
        for (i in startIndex..endIndex) {
            if (s[i] != skip) {
                return i
            }
        }
        return endIndex
    }

    public static func skipBackwards(skip: Byte, s: CharSequence, startIndex: Int, lastIndex: Int): Int {
        for (i in startIndex..=lastIndex : -1) {
            if (s[i] != skip) {
                return i
            }
        }
        return lastIndex - 1
    }

    public static func skipSpaceTab(s: CharSequence, startIndex: Int, endIndex: Int): Int {
        for (i in startIndex..endIndex) {
            match (s[i]) {
                case b' ' | b'\t' => break
                case _ => return i
            }
        }
        return endIndex
    }

    public static func skipSpaceTabBackwards(s: CharSequence, startIndex: Int, lastIndex: Int): Int {
        for (i in startIndex..=lastIndex : -1) {
            match (s[i]) {
                case b' ' | b'\t' => break
                case _ => return i
            }
        }
        return lastIndex - 1
    }
}
