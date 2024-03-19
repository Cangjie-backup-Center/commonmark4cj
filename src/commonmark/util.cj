package commonmark

/* Character range of ascii type：0-127*/
public type AsciiByte = Byte

public class Escaping {
    public static let ESCAPABLE: String = "[!\"#$%&\'()*+,./:;<=>?@\\[\\\\\\]^_`{|}~-]"

    public static let ENTITY: String = "&(?:#x[a-f0-9]{1,6}|#[0-9]{1,7}|[a-z][a-z0-9]{1,31});"

    private static let BACKSLASH_OR_AMP = Regex("[\\\\&]")

    private static let ENTITY_OR_ESCAPED_CHAR = Regex(
        "\\\\" + ESCAPABLE + '|'.toString() + ENTITY,
        RegexOption().ignoreCase()
    )

    // From RFC 3986 (see "reserved", "unreserved") except don't escape '[' or ']' to be compatible with JS encodeURI
    private static let ESCAPE_IN_URI = Regex("(%[a-fA-F0-9]{0,2}|[^:/?#@!$&'()*+,;=a-zA-Z0-9\\-._~])")

    private static let WHITESPACE = Regex("[ \t\r\n]+")

    public static func escapeHtml(input: String): String {
        // Avoid building a new string in the majority of cases (nothing to escape)
        let runesArray: Array<Rune> = input.toRuneArray()
        var sb: ?ArrayList<Rune> = None
        for (i in 0..runesArray.size) {
            var replacement: String = ""
            match (runesArray[i]) {
                case '&' => replacement = "&amp;"
                case '<' => replacement = "&lt;"
                case '>' => replacement = "&gt;"
                case '\"' => replacement = "&quot;"
                case _ =>
                    if (let Some(s) <- sb) {
                        s.append(runesArray[i])
                    }
                    continue
            }
            if (sb.isNone()) {
                sb = ArrayList<Rune>(i)
                sb().appendAll(runesArray[..i])
            }
            sb().appendAll(replacement.toRuneArray())
        }
        if (let Some(s) <- sb) {
            let size: Int64 = s.size
            return String(unsafe { s.getRawArray()[0..size] })
        } else {
            return input
        }
    }

    /**
     * Replace entities and backslash escapes with literal characters.
     */
    public static func unescapeString(s: String): String {
        match (BACKSLASH_OR_AMP.matcher(s).find()) {
            case None => return s
            case _ => return replaceAll(ENTITY_OR_ESCAPED_CHAR, s, UnescapeReplacer())
        }
    }

    public static func percentEncodeUrl(s: String): String {
        let str = s |> map<Byte, ToString> {
            b => if (b < 128) {
                String(Char(UInt32(b)))
            } else {
                "%${b.format("X")}"
            }
        } |> collectString(delimiter: "")
        return replaceAll(ESCAPE_IN_URI, str, UriReplacer())
    }

    protected static func normalizeReference(input: String): String {
        // Strip '[' and ']'
        let stripped: String = input[1..input.size - 1]
        return normalizeLabelContent(stripped)
    }

    protected static func normalizeLabelContent(input: String): String {
        let trimmed: String = input.trimAscii()
        let lowercase: String = trimmed.toAsciiLower()
        return WHITESPACE.matcher(lowercase).replaceAll(" ")
    }

    private static func replaceAll(p: Regex, s: String, replacer: Replacer): String {
        let matcher: Matcher = p.matcher(s)

        if (matcher.allCount() < 1) {
            return s
        }

        var sb: ArrayList<Rune> = ArrayList<Rune>(s.size + 16)
        var lastEnd: Int64 = 0

        var pos: Position
        while (let Some(md: MatchData) <- matcher.find()) {
            pos = md.matchPosition()
            sb.appendAll(s[lastEnd..pos.start].toRuneArray())
            replacer.replace(md.matchStr(), sb)
            lastEnd = pos.end
        }

        if (lastEnd != s.size) {
            sb.appendAll(s[lastEnd..].toRuneArray())
        }
        return String(unsafe { sb.getRawArray()[0..sb.size] })
    }
}

class UnescapeReplacer <: Replacer {
    public func replace(input: String, sb: ArrayList<Rune>): Unit {
        if (input[0] == b'\\') {
            sb.appendAll(input[1..].toRuneArray())
        } else {
            sb.appendAll(Html5Entities.entityToString(input).toRuneArray())
        }
    }
}

class UriReplacer <: Replacer {
    private static let HEX_DIGITS: Array<Rune> = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D',
    'E', 'F']

    public func replace(input: String, sb: ArrayList<Rune>): Unit {
        if (input[0] == b'%') {
            if (input.size == 3) {
                // Already percent-encoded, preserve
                sb.appendAll(input.toRuneArray())
            } else {
                // %25 is the percent-encoding for %
                sb.appendAll("%25".toRuneArray())
                sb.appendAll(input[1..].toRuneArray())
            }
        } else {
            let bytes: Array<UInt8> = input.toArray()
            for (b in bytes) {
                sb.append('%')
                sb.append(HEX_DIGITS[Int64((b >> 4) & 0xF)])
                sb.append(HEX_DIGITS[Int64(b & 0xF)])
            }
        }
    }
}

public interface Replacer {
    func replace(input: String, sb: ArrayList<Rune>): Unit
}

public class Html5Entities {
    private static let NAMED_CHARACTER_REFERENCES: Map<String, String> = readEntities()
    private static let NUMERIC_PATTERN = Regex("^&#[Xx]?")

    protected static func entityToString(input: String): String {
        let matcher: Matcher = NUMERIC_PATTERN.matcher(input)
        let md: ?MatchData = matcher.find()
        if (md.isSome()) {
            try {
                let codePointString: String = input[md.getOrThrow().matchPosition().end..input.size - 1]
                let codePoint: Int64
                if (md.getOrThrow().matchPosition().end == 2) {
                    codePoint = Int64.parse(codePointString)
                } else {
                    codePoint = Int64.parse("0x" + codePointString)
                }
                if (codePoint == 0) {
                    return "\u{FFFD}"
                }

                return String(Char(codePoint))
            } catch (e: IllegalArgumentException) {
                return "\u{FFFD}"
            }
        } else {
            let name: String = input[1..input.size - 1]
            let s: ?String = NAMED_CHARACTER_REFERENCES.get(name)
            return s ?? input
        }
    }

    public static func readEntities(): HashMap<String, String> {
        return entities_dict
    }
}

class LinkScanner {

    /**
     * Attempt to scan the contents of a link label (inside the brackets), returning the position after the content or
     * -1. The returned position can either be the closing {@code ]}, or the end of the line if the label continues on
     * the next line.
     */
    public static func scanLinkLabelContent(input: CharSequence, start: Int64): Int64 {
        var i: Int64 = start
        while (i < input.size) {
            let c = input[i]
            match (c) {
                case '\\' => if (Parsing.isEscapable(input, i + 1)) {
                    i++
                }
                case ']' => return i
                case '[' =>
                    // spec: Unescaped square bracket characters are not allowed inside the opening and closing
                    // square brackets of link labels.
                    return -1
                case _ => ()
            }
            i++
        }
        return input.size
    }

    /**
     * Attempt to scan a link destination, returning the position after the destination or -1.
     */
    public static func scanLinkDestination(input: Array<Rune>, start: Int64): Int64 {
        if (start >= input.size) {
            return -1
        }
        if (input[start] == '<') {
            var i: Int64 = start + 1
            while (i < input.size) {
                let c = input[i]
                match (c) {
                    case '\\' => if (Parsing.isEscapable(input, i + 1)) {
                        i++
                    }
                    case '\n' | '<' => return -1
                    case '>' => return i + 1
                    case _ => ()
                }
                i++
            }
            return -1
        } else {
            return scanLinkDestinationWithBalancedParens(input, start)
        }
    }

    public static func scanLinkTitle(input: CharSequence, start: Int64): Int64 {
        if (start >= input.size) {
            return -1
        }

        var endDelimiter: Rune
        match (input[start]) {
            case '"' => endDelimiter = '"'
            case '\'' => endDelimiter = '\''
            case '(' => endDelimiter = ')'
            case _ => return -1
        }

        let afterContent: Int64 = scanLinkTitleContent(input, start + 1, endDelimiter)
        if (afterContent == -1) {
            return -1
        }

        if (afterContent >= input.size || input[afterContent] != endDelimiter) {
            // missing or wrong end delimiter
            return -1
        }

        return afterContent + 1
    }

    /*
     * simple bitmap
     */
    public static func scanLinkTitleContent(input: CharSequence, start: Int64, endDelimiter: Rune): Int64 {
        var i: Int64 = start
        while (i < input.size) {
            let c = input[i]
            if (c == '\\' && Parsing.isEscapable(input, i + 1)) {
                i++
            } else if (c == endDelimiter) {
                return i
            } else if (endDelimiter == ')' && c == '(') {
                // unescaped '(' in title within parens is invalid
                return -1
            }
            i++
        }
        return input.size
    }

    // spec: a nonempty sequence of characters that does not start with <, does not include ASCII space or control
    // characters, and includes parentheses only if (a) they are backslash-escaped or (b) they are part of a balanced
    // pair of unescaped parentheses
    private static func scanLinkDestinationWithBalancedParens(input: CharSequence, start: Int64): Int64 {
        var parens: Int64 = 0
        var i: Int64 = start
        while (i < input.size) {
            let c = input[i]
            match (c) {
                case '\0' | ' ' => if (i != start) {
                    return i
                } else {
                    return -1
                }
                case '\\' => if (Parsing.isEscapable(input, i + 1)) {
                    i++
                }
                case '(' =>
                    parens++
                    // Limit to 32 nested parens for pathological cases
                    if (parens > 32) {
                        return -1
                    }
                case ')' => if (parens == 0) {
                    return i
                } else {
                    parens--
                }
                case _ =>
                    // or control character
                    if (isISOControl(c)) {
                    if (i != start) {
                        return i
                    } else {
                        return -1
                    }
                } else {
                    i += 1
                    continue
                }
            }
            i++
        }
        return input.size
    }
    private static func isISOControl(codePoint: Rune): Bool {
        let u32 = UInt32(codePoint)
        return u32 <= 0x9F && (u32 >= 0x7F || (u32 >> 5 == 0x00))
    }
}

class Parsing {
    private static let bytes: Array<Byte> = [b'!', b'"', b'#', b'$', b'%', b'&', b'\'', b'(', b')', b'*', b'+', b',',
    b'-', b'.', b'/', b':', b';', b'<', b'=', b'>', b'?', b'@', b'[', b'\\', b']', b'^', b'_', b'`', b'{', b'|', b'}',
    b'~']
    private static let TAGNAME: String = "[A-Za-z][A-Za-z0-9-]*"
    private static let ATTRIBUTENAME: String = "[a-zA-Z_:][a-zA-Z0-9:._-]*"
    private static let UNQUOTEDVALUE: String = "[^\"'=<>`\\x00-\\x20]+"
    private static let SINGLEQUOTEDVALUE: String = "'[^']*'"
    private static let DOUBLEQUOTEDVALUE: String = "\"[^\"]*\""
    private static let ATTRIBUTEVALUE: String = "(?:" + UNQUOTEDVALUE + "|" + SINGLEQUOTEDVALUE + "|" + DOUBLEQUOTEDVALUE +
        ")"
    private static let ATTRIBUTEVALUESPEC: String = "(?:" + "\\s*=" + "\\s*" + ATTRIBUTEVALUE + ")"
    private static let ATTRIBUTE: String = "(?:" + "\\s+" + ATTRIBUTENAME + ATTRIBUTEVALUESPEC + "?)"

    public static let OPENTAG: String = "<" + TAGNAME + ATTRIBUTE + "*" + "\\s*/?>"
    public static let CLOSETAG: String = "</" + TAGNAME + "\\s*[>]"

    public static let CODE_BLOCK_INDENT: Int64 = 4

    public static func columnsToNextTabStop(column: Int64): Int64 {
        // Tab stop is 4
        return 4 - (column % 4)
    }

    /**
     * Byte is ascii
     */
    public static func find(c: Rune, s: CharSequence, startIndex: Int64): Int64 {
        let length: Int64 = s.size
        for (i in startIndex..length) {
            if (s[i] == c) {
                return i
            }
        }
        return -1
    }

    public static func findLineBreak(s: CharSequence, startIndex: Int64): Int64 {
        let length: Int64 = s.size
        for (i in startIndex..length) {
            match (s[i]) {
                case '\n' | '\r' => return i
                case _ => ()
            }
        }
        return -1
    }

    public static func isBlank(s: CharSequence): Bool {
        return findNonSpace(s, 0) == -1
    }

    public static func hasNonSpace(s: CharSequence): Bool {
        let length: Int64 = s.size
        let skipped: Int64 = skip(' ', s, 0, length)
        return skipped != length
    }

    public static func isLetter(s: CharSequence, index: Int64): Bool {
        return s[index].isLetter()
    }

    public static func isSpaceOrTab(s: CharSequence, index: Int64): Bool {
        if (index < s.size) {
            match (s[index]) {
                case ' ' | '\t' => return true
                case _ => ()
            }
        }
        return false
    }

    // public static func isEscapable(s: String, index: Int64): Bool {
    //     if (index < s.size) {
    //         if (bytes.contains(s[index])) {
    //             return true
    //         }
    //     }
    //     return false
    // }

    public static func isEscapable(s: CharSequence, index: Int64): Bool {
        if (index < s.size) {
            if (bytes.contains(UInt8(UInt32(s[index])) & 0xff)) {
                return true
            }
        }
        return false
    }

    /**
     * Prepares the input line replacing {@code \0}
     */
    public static func prepareLine(line: CharSequence): CharSequence {
        // Avoid building a new string in the majority of cases (no \0)
        for (i in 0..line.size) {
            if (line[i] == '\0') {
                line[i] = '\u{FFFD}'
            }
        }
        return line
    }

    public static func skip(skip: Rune, s: CharSequence, startIndex: Int64, endIndex: Int64): Int64 {
        for (i in startIndex..endIndex) {
            if (s[i] != skip) {
                return i
            }
        }
        return endIndex
    }

    public static func skipBackwards(skip: Rune, s: CharSequence, startIndex: Int64, lastIndex: Int64): Int64 {
        for (i in startIndex..lastIndex : -1) {
            if (s[i] != skip) {
                return i
            }
        }
        return lastIndex - 1
    }

    public static func skipSpaceTab(s: CharSequence, startIndex: Int64, endIndex: Int64): Int64 {
        for (i in startIndex..endIndex) {
            match (s[i]) {
                case ' ' | '\t' => continue
                case _ => return i
            }
        }
        return endIndex
    }

    public static func skipSpaceTabBackwards(s: CharSequence, startIndex: Int64, lastIndex: Int64): Int64 {
        for (i in startIndex..lastIndex : -1) {
            match (s[i]) {
                case ' ' | '\t' => continue
                case _ => return i
            }
        }
        return lastIndex - 1
    }

    private static func findNonSpace(s: CharSequence, startIndex: Int64): Int64 {
        let length: Int64 = s.size
        for (i in startIndex..length) {
            match (s[i]) {
                case ' ' | '\t' | '\n' | '\u{0B}' | '\f' | '\r' => continue
                case _ => return i
            }
        }
        return -1
    }
}
