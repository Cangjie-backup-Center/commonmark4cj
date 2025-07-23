/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package markdown.plugin

import std.collection.collectArray
import std.collection.collectArrayList

const NO_END: Int = -2
/**
 * @see InlineHtmlTag
 * @see BlockHtmlTag
 */
public interface HtmlTag <: ToString {
    /**
     * @return normalized tag name (lower-case)
     */
    //    @NonNull
    func name(): String

    /**
     * @return index at which this tag starts
     */
    func start(): Int

    /**
     * @return index at which this tag ends
     */
    func end(): Int

    /**
     * @return flag indicating if this tag has no content (when start == end)
     */
    func isEmpty(): Bool

    /**
     * @return flag indicating if this tag is closed (has valid start and end)
     * @see #NO_END
     */
    func isClosed(): Bool

    func closeAt(end: Int): Unit

    //    @NonNull
    func attributes(): Map<String, String>

    /**
     * @see InlineHtmlTag
     */
    func isInline(): Bool

    /**
     * @see BlockHtmlTag
     */
    func isBlock(): Bool

    //    @NonNull
    func getAsInline(): InlineHtmlTag

    //    @NonNull
    func getAsBlock(): BlockHtmlTag

    mut prop parentTag: ?HtmlTag
    func getChildren(): ArrayList<HtmlTag>
    func appendChild(tag: HtmlTag): Unit {
        getChildren().add(tag)
        tag.parentTag = this
    }
}

/**
 * Represents <em>really</em> inline HTML tags (unlile commonmark definitions)
 */
public interface InlineHtmlTag <: HtmlTag {}

/**
 * Represents HTML block tags. Please note that all tags that are not inline should be
 * considered as block tags
 */
public interface BlockHtmlTag <: HtmlTag {

    /**
     * @return parent {@link BlockHtmlTag} or None if there is no parent (this block is at root level)
     */
    //    @Nullable
    func parent(): ?BlockHtmlTag

    /**
     * @return list of children
     */
    //    @NonNull
    func children(): Collection<BlockHtmlTag>

    /**
     * @return a flag indicating if this {@link BlockHtmlTag} is at the root level (shortcut to calling:
     * {@code parent().isNone()}
     */
    func isRoot(): Bool
}

public abstract class HtmlTagImpl <: HtmlTag {
    let _name: String
    let _start: Int
    let _attributes: Map<String, String>
    var _end: Int = NO_END
    var _parentTag: ?HtmlTag = None
    var childrenTag: ?ArrayList<HtmlTag> = None

    protected HtmlTagImpl(name: String, start: Int, attributes: Map<String, String>) {
        this._name = name
        this._start = start
        this._attributes = attributes
    }

    //    @NonNull
    public override func name(): String {
        return _name
    }

    public override func start(): Int {
        return _start
    }

    public override func end(): Int {
        return _end
    }

    public override func isEmpty(): Bool {
        return _start == _end
    }

    //    @NonNull
    public open override func attributes(): Map<String, String> {
        return _attributes
    }

    public override func isClosed(): Bool {
        return _end > NO_END
    }

    public mut override prop parentTag: ?HtmlTag {
        get() {
            _parentTag
        }
        set(v) {
            _parentTag = v
        }
    }
    public override func getChildren(): ArrayList<HtmlTag> {
        match (childrenTag) {
            case Some(v) => v
            case _ =>
                let arr = ArrayList<HtmlTag>()
                childrenTag = arr
                arr
        }
    }
    public override func appendChild(tag: HtmlTag): Unit {
        getChildren().add(tag)
        tag.parentTag = this
    }
}

public open class InlineImpl <: HtmlTagImpl & InlineHtmlTag {
    InlineImpl(name: String, start: Int, attributes: Map<String, String>) {
        super(name, start, attributes)
    }

    public override func closeAt(end: Int): Unit {
        if (!isClosed()) {
            super._end = end
        }
    }

    public override func toString(): String {
        return "InlineImpl{name='${_name}', start=${_start}, end=${_end}, attributes=${"_attributes"}"
    }

    public override func isInline(): Bool {
        return true
    }

    public override func isBlock(): Bool {
        return false
    }

    //    @NonNull
    public override func getAsInline(): InlineHtmlTag {
        return this
    }

    //    @NonNull
    public override func getAsBlock(): BlockHtmlTag {
        throw UnsupportedException("Cannot cast InlineHtmlTag instance to BlockHtmlTag")
    }
}

public class BlockImpl <: HtmlTagImpl & BlockHtmlTag {
    //    @NonNull
    static func root(): BlockImpl {
        return BlockImpl("_root_", 0, HashMap<String, String>(), None, None)
    }

    //    @NonNull
    static func create(
        name: String,
        start: Int,
        attributes: Map<String, String>,
        parent: ?BlockImpl,
        parentTag: ?HtmlTag
    ): BlockImpl {
        return BlockImpl(name, start, attributes, parent, parentTag)
    }

    let _parent: ?BlockImpl
    var _children: ?ArrayList<BlockImpl> = None

    BlockImpl(
        name: String,
        start: Int,
        attributes: Map<String, String>,
        parent: ?BlockImpl,
        parentTag: ?HtmlTag
    ) {
        super(name, start, attributes)
        this._parent = parent
        if (let Some(p) <- parentTag) {
            p.appendChild(this)
        }
    }

    public override func closeAt(end: Int): Unit {
        if (!isClosed()) {
            super._end = end
            if (let Some(children) <- _children) {
                for (child in children) {
                    child.closeAt(end)
                }
            }
        }
    }

    public override func isRoot(): Bool {
        return _parent.isNone()
    }

    //    @Nullable
    public override func parent(): ?BlockHtmlTag {
        return _parent ?? None
    }

    //    @NonNull
    public override func children(): ArrayList<BlockHtmlTag> {
        let list: ArrayList<BlockHtmlTag>
        if (let Some(children) <- _children) {
            list = children |> map<BlockImpl, BlockHtmlTag> {v => v} |> collectArrayList
        } else {
            list = ArrayList<BlockHtmlTag>()
        }
        return list
    }

    //    @NonNull
    public override func attributes(): Map<String, String> {
        return _attributes
    }

    public override func isInline(): Bool {
        return false
    }

    public override func isBlock(): Bool {
        return true
    }

    //    @NonNull
    public override func getAsInline(): InlineHtmlTag {
        throw UnsupportedException("Cannot cast BlockHtmlTag instance to InlineHtmlTag")
    }

    //    @NonNull
    public override func getAsBlock(): BlockHtmlTag {
        return this
    }

    public override func toString(): String {
        return "BlockImpl{name='${_name}', start=${_start}, end=${_end}, attributes=${"_attributes"}, parent=${_parent?._name ?? "None"}, children=${_children}"
    }
}

/**
 * html中的Text部分 视为一种叶子节点
 */
public class TextTag <: HtmlTagImpl {
    private static let EMPTY_MAP: Map<String, String> = HashMap<String, String>()
    let text: String
    TextTag(text: String) {
        super("", -1, EMPTY_MAP)
        this.text = text
        _end = 0
    }
    public override func closeAt(end: Int): Unit {
        _end = end
    }
    public override func attributes(): Map<String, String> {
        throw UnsupportedException()
    }
    public override func isInline(): Bool {
        true
    }
    public override func isBlock(): Bool {
        false
    }
    public override func getAsInline(): InlineHtmlTag {
        throw UnsupportedException()
    }
    public override func getAsBlock(): BlockHtmlTag {
        throw UnsupportedException()
    }
    public override func toString(): String {
        "TextTag{${text.replace("\n","\\n")}}"
    }
}
/**
 * html中的EndTag
 */
public class EndTag <: HtmlTagImpl {
    private static let EMPTY_MAP: Map<String, String> = HashMap<String, String>()
    var startTag: ?HtmlTag = None
    init(tagName: String, startTag: ?HtmlTag) {
        super(tagName, -1, EMPTY_MAP)
        this.startTag = startTag
    }
    public override func closeAt(_: Int): Unit {
        throw UnsupportedException()
    }
    public override func attributes(): Map<String, String> {
        throw UnsupportedException()
    }
    public override func isInline(): Bool {
        false
    }
    public override func isBlock(): Bool {
        false
    }
    public override func getAsInline(): InlineHtmlTag {
        throw UnsupportedException()
    }
    public override func getAsBlock(): BlockHtmlTag {
        throw UnsupportedException()
    }
    public override func toString(): String {
        "EndTag{${_name}}"
    }
}
