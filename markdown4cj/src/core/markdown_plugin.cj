/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Created on 028 24/2/28
 */
package markdown.core

/**
 * Class represents a plugin (extension) to Markdown to configure how parsing and rendering
 * of markdown is carried on.
 *
 * @see AbstractMarkdownPlugin
 * @see CorePlugin
 * @see MovementMethodPlugin
 */
public interface MarkdownPlugin <: Hashable & Equatable<MarkdownPlugin> & ToString {
    func getClassType(): String
    /**
     * This method will be called before any other during {@link Markdown} instance construction.
     */
    func configure(registry: Registry): Unit

    /**
     * Method to configure <code>commonmark.Parser</code>
     * for example register custom extension, etc.
     */
    func configureParser(builder: ParserBuilder): Unit

    /**
     * Configure {@link MarkdownVisitor} to accept node types or override already registered nodes.
     *
     * @see MarkdownVisitor
     * @see MarkdownVisitorBuilder
     */
    func configureVisitor(builder: MarkdownVisitorBuilder): Unit

    /**
     * Process input markdown and return string to be used in parsing stage further.
     * Can be described as <code>pre-processing</code> of markdown String.
     *
     * @param markdown String to process
     * @return processed markdown String
     */
    func processMarkdown(markdown: String): String

    /**
     * This method will be called <strong>before</strong> rendering will occur thus making possible
     * to <code>post-process</code> parsed node (make changes for example).
     *
     * @param node root parsed commonmark.Node
     */
    func beforeRender(node: Node): Unit

    /**
     * This method will be called <strong>after</strong> rendering (but before applying markdown to a
     * TextView, if such action will happen). It can be used to clean some
     * internal state, or trigger certain action. Please note that modifying <code>node</code> won\'t
     * have any effect as it has been already <i>visited</i> at this stage.
     *
     * @param node    root parsed commonmark.Node
     * @param visitor {@link MarkdownVisitor} instance used to render markdown
     */
    func afterRender(node: Node, visitor: MarkdownVisitor): Unit
}

/**
 * @see Registry#require(Class, Action)
 */
type Action = (p: MarkdownPlugin) -> Unit

/**
 * Class that <: {@link MarkdownPlugin} with all methods implemented (empty body)
 * for easier plugin implementation. Only required methods can be overriden
 *
 * @see MarkdownPlugin
 */
public abstract class AbstractMarkdownPlugin <: MarkdownPlugin {
    public open override func configure(_: Registry): Unit {
    }

    public open override func configureParser(_: ParserBuilder): Unit {
    }

    public open override func configureVisitor(_: MarkdownVisitorBuilder): Unit {
    }

    public open override func processMarkdown(markdown: String): String {
        return markdown
    }

    public open override func beforeRender(_: Node): Unit {
    }

    public open override func afterRender(_: Node, _: MarkdownVisitor): Unit {
    }

    public open operator func ==(other: MarkdownPlugin): Bool {
        return refEq(this, (other as AbstractMarkdownPlugin)())
    }
    public open operator func !=(other: MarkdownPlugin): Bool {
        return !(this == other)
    }

    private let _hashCode = DateTime.now().hashCode()
    public open func hashCode(): Int {
        _hashCode
    }

    public func toString(): String {
        "${this.getClassType()}@${_hashCode}"
    }
}
