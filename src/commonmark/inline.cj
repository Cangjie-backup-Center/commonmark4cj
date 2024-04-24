package commonmark

public abstract class EmphasisDelimiterProcessor <: DelimiterProcessor {
    private let delimiterChar: Char

    protected init(delimiterChar: Char) {
        this.delimiterChar = delimiterChar
    }

    public override func getOpeningCharacter(): Char {
        return delimiterChar
    }

    public override func getClosingCharacter(): Char {
        return delimiterChar
    }

    public override func getMinLength(): Int64 {
        return 1
    }

    public override func getDelimiterUse(opener: DelimiterRun, closer: DelimiterRun): Int64 {
        // "multiple of 3" rule for internal delimiter runs
        if ((opener.canClose() || closer.canOpen()) && closer.getOriginalLength() % 3 != 0 &&
            (opener.getOriginalLength() + closer.getOriginalLength()) % 3 == 0) {
            return 0
        }
        // calculate actual number of delimiters used from this closer
        if (opener.getLength() >= 2 && closer.getLength() >= 2) {
            return 2
        } else {
            return 1
        }
    }

    public override func process(opener: Text, closer: Text, delimiterUse: Int64): Unit {
        let singleDelimiter: String = String(getOpeningCharacter())
        let emphasis: Node = if (delimiterUse == 1) {
            Emphasis(singleDelimiter)
        } else {
            StrongEmphasis(singleDelimiter + singleDelimiter)
        }
        var tmp: ?Node = opener.getNext()
        while (let Some(v) <- tmp) {
            if (v == closer) {
                break
            }
            let next: ?Node = v.getNext()
            emphasis.appendChild(v)
            tmp = next
        }

        opener.insertAfter(emphasis)
    }
}

public class UnderscoreDelimiterProcessor <: EmphasisDelimiterProcessor {
    public init() {
        super('_')
    }
}

public class AsteriskDelimiterProcessor <: EmphasisDelimiterProcessor {
    public init() {
        super('*')
    }
}
