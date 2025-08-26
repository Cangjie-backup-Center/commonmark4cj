/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights resvered.
 */
package commonmark4cj.commonmark

public class LinkScanner {
    /**
     * Attempt to scan the contents of a link label (inside the brackets), stopping after the content or returning false.
     * The stopped position can bei either the closing {@code ]}, or the end of the line if the label continues on
     * the next line.
     */
    public static func scanLinkLabelContent(scanner: Scanner): Bool {
        while (scanner.hasNext()) {
            match (scanner.peekByte()) {
                case '\\' =>
                    scanner.nextByte()
                    if (isEscapable(scanner.peekByte())) {
                        scanner.nextByte()
                    }
                case ']' => return true
                case '[' =>
                    // spec: Unescaped square bracket characters are not allowed inside the opening and closing
                    // square brackets of link labels.
                    return false
                case _ => scanner.nextByte()
            }
        }
        return true
    }

    /**
     * Attempt to scan a link destination, stopping after the destination or returning false.
     */
    public static func scanLinkDestination(scanner: Scanner): Bool {
        if (!scanner.hasNext()) {
            return false
        }

        if (scanner.nextByte(b'<')) {
            while (scanner.hasNext()) {
                match (scanner.peekByte()) {
                    case '\\' =>
                        scanner.nextByte()
                        if (isEscapable(scanner.peekByte())) {
                            scanner.nextByte()
                        }
                    case '\n' | '<' => return false
                    case '>' =>
                        scanner.nextByte()
                        return true
                    case _ => scanner.nextByte()
                }
            }
            return false
        } else {
            return scanLinkDestinationWithBalancedParens(scanner)
        }
    }

    public static func scanLinkTitle(scanner: Scanner): Bool {
        if (!scanner.hasNext()) {
            return false
        }

        let endDelimiter: Byte = match (scanner.peekByte()) {
            case '"' => b'"'
            case '\'' => b'\''
            case '(' => b')'
            case _ => return false
        }
        scanner.nextByte()

        if (!scanLinkTitleContent(scanner, endDelimiter)) {
            return false
        }
        if (!scanner.hasNext()) {
            return false
        }
        scanner.nextByte()
        return true
    }

    public static func scanLinkTitleContent(scanner: Scanner, endDelimiter: Byte): Bool {
        while (scanner.hasNext()) {
            let c: Byte = scanner.peekByte()
            if (c == b'\\') {
                scanner.nextByte()
                if (isEscapable(scanner.peekByte())) {
                    scanner.nextByte()
                }
            } else if (c == endDelimiter) {
                return true
            } else if (endDelimiter == b')' && c == b'(') {
                // unescaped '(' in title within parens is invalid
                return false
            } else {
                scanner.nextByte()
            }
        }
        return true
    }

    // spec: a nonempty sequence of characters that does not start with <, does not include ASCII space or control
    // characters, and includes parentheses only if (a) they are backslash-escaped or (b) they are part of a balanced
    // pair of unescaped parentheses
    private static func scanLinkDestinationWithBalancedParens(scanner: Scanner): Bool {
        var parens = 0
        var empty = true
        while (scanner.hasNext()) {
            let c = scanner.peekByte()
            match (c) {
                case ' ' => return !empty
                case '\\' =>
                    scanner.nextByte()
                    if (isEscapable(scanner.peekByte())) {
                        scanner.nextByte()
                    }
                case '(' =>
                    parens++
                    // Limit to 32 nested parens for pathological cases
                    if (parens > 32) {
                        return false
                    }
                    scanner.nextByte()
                case ')' =>
                    if (parens == 0) {
                        return true
                    } else {
                        parens--
                    }
                    scanner.nextByte()
                case _ =>
                    let char = scanner.peek()
                    // or control character
                    if (isISOControl(char)) {
                        return !empty
                    }
                    scanner.next()
            }
            empty = false
        }
        return true
    }

    private static func isEscapable(c: Byte): Bool {
        match (c) {
            case '!' | '"' | '#' | '$' | '%' | '&' | '\'' | '(' | ')' | '*' | '+' | ',' | '-' | '.' | '/' | ':' | ';'
                | '<' | '=' | '>' | '?' | '@' | '[' | '\\' | ']' | '^' | '_' | '`' | '{' | '|' | '}' | '~' => return true
            case _ => return false
        }
    }

    private static func isISOControl(codePoint: Rune): Bool {
        let u32 = UInt32(codePoint)
        return u32 <= 0x9F && (u32 >= 0x7F || (u32 >> 5 == 0x00))
    }
}
