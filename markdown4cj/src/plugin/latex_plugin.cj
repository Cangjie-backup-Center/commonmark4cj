/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

public class LatexMathBlock <: CustomBlock {
    private var _latex: String = ""
    public mut prop latex: String {
        get() {
            _latex
        }
        set(v) {
            _latex = v
        }
    }
    public var isClosed = false
    public var isBroken = false
    protected func toStringAttributes(): String {
        return "latex=${latex},isClosed=${isClosed},isBroken=${isBroken}"
    }
    public func getNodeType(): String {
        "LatexMathBlock"
    }
}

public class LatexMathNode <: CustomNode {
    public LatexMathNode(public var latex: String) {}
    protected func toStringAttributes(): String {
        return "latex=${latex}"
    }
    public func getNodeType(): String {
        "LatexMathNode"
    }
}
