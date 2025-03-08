/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights resvered.
 */

package commonmark4cj.commonmark

/**
 * 为了\(...\)数学公式的解析，自定义一个Text节点
 * 若不特殊处理，其表现为Text
 */
public open class LatexInlineText <: CustomNode {
    public LatexInlineText(let literal: String) {}
    public func getLiteral(): String {
        return literal
    }
    public func getNodeType() {
        "LatexInlineText"
    }
}

public let needLatexInlineParse = [false]

func tryLatexInlineStart(r: Rune): Bool {
    needLatexInlineParse[0] && (r == r"(" || r == r"[")
}

let LATEX_INLINE_REGEX_1 = Regex(#"\(.+?\\\)"#)
let LATEX_INLINE_REGEX_2 = Regex(#"\[.+?\\\]"#)

func matchLatexInline(str: String): ?(Node, Int) {
    var matcher = LATEX_INLINE_REGEX_1.matcher(str)
    if (let Some(data) <- matcher.find()) {
        let pos = data.matchPosition()
        let latex = str[(pos.start + 1)..(pos.end - 2)]
        let latexInline = LatexInlineText(latex)
        return (latexInline, pos.end)
    }
    matcher = LATEX_INLINE_REGEX_2.matcher(str)
    if (let Some(data) <- matcher.find()) {
        let pos = data.matchPosition()
        let latex = str[(pos.start + 1)..(pos.end - 2)]
        let latexInline = LatexInlineText(latex)
        return (latexInline, pos.end)
    }
    return None
}
