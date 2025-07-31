/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package commonmark4cj.strikethrough

let StrikethroughType: NodeType = "Strikethrough"

public abstract class StrikethroughNodeRenderer <: NodeRenderer {
    public override func getNodeTypes(): HashSet<NodeType> {
        return HashSet<NodeType>([StrikethroughType])
    }
}

/**
 * A strikethrough node containing text and other inline nodes nodes as children.
 */
public class Strikethrough <: CustomNode & Delimited {
    private static let DELIMITER: String = "~~"

    public override func getOpeningDelimiter(): ?String {
        return DELIMITER
    }

    public override func getClosingDelimiter(): ?String {
        return DELIMITER
    }

    public override func getNodeType(): NodeType {
        return StrikethroughType
    }
}

class StrikethroughDelimiterProcessor <: DelimiterProcessor {
    public override func getOpeningCharacter(): Rune {
        return r'~'
    }

    public override func getClosingCharacter(): Rune {
        return r'~'
    }

    public override func getMinLength(): Int64 {
        return 2
    }

    public override func getDelimiterUse(opener: DelimiterRun, closer: DelimiterRun): Int64 {
        if (opener.getLength() >= 2 && closer.getLength() >= 2) {
            // Use exactly two delimiters even if we have more, and don't care about internal openers/closers.
            return 2
        } else {
            return 0
        }
    }

    public override func process(opener: Text, closer: Text, _: Int64): Unit {
        // Wrap nodes between delimiters in strikethrough.
        var strikethrough: Node = Strikethrough()

        var tmp: ?Node = opener.getNext()
        while (let Some(v) <- tmp && v != closer) {
            tmp = v.getNext()
            strikethrough.appendChild(v)
        }

        opener.insertAfter(strikethrough)
    }
}

public class StrikethroughExtension <: ParserExtension {
    private init() {}

    public static func create(): Extension {
        return StrikethroughExtension()
    }

    public override func ext(parserBuilder: ParserBuilder): Unit {
        parserBuilder.customDelimiterProcessor(StrikethroughDelimiterProcessor())
    }

}
