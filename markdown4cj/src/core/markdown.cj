/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Created on 028 24/2/28
 */
package markdown.core

/**
 * Class to parse and render markdown. instance specific (previously consisted
 * of static stateless methods). An instance of builder can be obtained via {@link #builder()}
 * method.
 *
 * @see #create()
 * @see #builder()
 * @see Builder
 */
public abstract class Markdown {
    /**
     * Factory method to create a <em>minimally</em> functional {@link Markdown} instance. This
     * instance will have <strong>only</strong> {@link CorePlugin} registered. If you wish
     * to configure this instance more consider using {@link #builder()} method.
     *
     * @return {@link Markdown} instance with only CorePlugin registered
     */
    public static func create(): Markdown {
        return builder().usePlugin(CorePlugin.create()).build()
    }

    /**
     * Factory method to obtain an instance of {@link Builder} with {@link CorePlugin} added.
     *
     * @see Builder
     * @see #builderNoCore()
     */
    public static func builder(): MarkdownBuilder {
        return MarkdownBuilderImpl().usePlugin(CorePlugin.create())
    }

    /**
     * Factory method to obtain an instance of {@link Builder} without {@link CorePlugin}.
     */
    public static func builderNoCore(): MarkdownBuilder {
        return MarkdownBuilderImpl()
    }

    /**
     * Method to parse markdown (without rendering)
     *
     * @param input markdown input to parse
     * @return parsed via commonmark <code>commonmark.Node</code>
     * @see #render(Node)
     */
    public func parse(input: String): Node

    /**
     * Create markdown:Spanned from parsed Node (via {@link #parse(String)} call).
     * <p>
     * Please note that returned Spanned has few limitations. For example, images, tables
     * and ordered lists require TextView to be properly displayed. This is why images and tables
     * most likely won\'t work in this case. Ordered lists might have mis-measurements. Whenever
     * possible use {@link #setMarkdown(TextView, String)} or {@link #setParsedMarkdown(TextView, Spanned)}
     * as these methods will additionally call specific {@link MarkdownPlugin} methods to <em>prepare</em>
     * proper display.
     */
    public func render(node: Node): NodeView

    /**
     * This method will {@link #parse(String)} and {@link #render(Node)} supplied markdown. Returned
     * Spanned has the same limitations as from {@link #render(Node)} method.
     *
     * @param input markdown input
     * @see #parse(String)
     * @see #render(Node)
     */
    public func toMarkdown(input: String): NodeView

    /**
     * Requests information if certain plugin has been registered. Please note that this
     * method will check for super classes also, so if supplied with {@code markdown.hasPlugin(MarkdownPlugin.class)}
     * this method (if has at least one plugin) will return true. If for example a custom
     * (subclassed) version of a {@link CorePlugin} has been registered and given name
     * {@code CorePlugin2}, then both {@code markdown.hasPlugin(CorePlugin2.class)} and
     * {@code markdown.hasPlugin(CorePlugin.class)} will return true.
     *
     * @param plugin type to query
     * @return true if a plugin is used when configuring this {@link Markdown} instance
     */
    public func hasPlugin(plugin: String): Bool

    // @Nullable
    public func getPlugin(plugin: String): ?MarkdownPlugin

    public func requirePlugin(pluginType: String): MarkdownPlugin

    /**
     * @return a list of registered {@link MarkdownPlugin}
     */
    public func getPlugins(): ArrayList<MarkdownPlugin>
}

class MarkdownImpl <: Markdown {
    private let parser: Parser
    private let visitorFactory: MarkdownVisitorFactory
    private let plugins: ArrayList<MarkdownPlugin>

    private let fallbackToRawInputWhenEmpty: Bool

    init(
        parser: Parser,
        visitorFactory: MarkdownVisitorFactory,
        plugins: ArrayList<MarkdownPlugin>,
        fallbackToRawInputWhenEmpty: Bool
    ) {
        this.parser = parser
        this.visitorFactory = visitorFactory
        this.plugins = plugins
        this.fallbackToRawInputWhenEmpty = fallbackToRawInputWhenEmpty
    }

    public override func parse(inputStr: String): Node {
        var input = inputStr
        // make sure that all plugins are called `processMarkdown` before parsing
        for (plugin in plugins) {
            input = plugin.processMarkdown(input)
        }

        return parser.parse(input)
    }

    public override func render(node: Node): NodeView {
        for (plugin in plugins) {
            plugin.beforeRender(node)
        }

        // obtain visitor via factory
        let visitor: MarkdownVisitor = visitorFactory()

        node.accept(visitor)

        for (plugin in plugins) {
            plugin.afterRender(node, visitor)
        }

        //noinspection UnnecessaryLocalVariable
        // let spanned: Spanned = visitor.builder().spannableStringBuilder()

        // clear render props and builder after rendering
        // as we no longer reuse visitor - there is no need to clean it
        // we might still do it if we introduce a thread-local storage though visitor.clear()
        return node.getView()
    }

    public override func toMarkdown(input: String): NodeView {
        let spanned: NodeView = try {
            let tree = parse(input)
            render(tree)
        } catch (e: Exception) {
            // if spanned is empty, we are configured to use raw input and input is not empty
            if (fallbackToRawInputWhenEmpty) {
                let text = Text(input)
                let p = Paragraph()
                p.appendChild(text)
                let doc = Document()
                doc.appendChild(p)
                render(doc)
            } else {
                throw e
            }
        }

        return spanned
    }

    public override func hasPlugin(pluginType: String): Bool {
        return getPlugin(pluginType).isSome()
    }

    // @Nullable
    public override func getPlugin(pluginType: String): ?MarkdownPlugin {
        var out: ?MarkdownPlugin = None
        for (plugin in plugins) {
            if (pluginType == plugin.getClassType()) {
                out = plugin
            }
        }
        //noinspection unchecked
        return out
    }

    public override func requirePlugin(pluginType: String): MarkdownPlugin {
        let plugin = getPlugin(pluginType)
        if (let Some(v) <- plugin) {
            return v
        } else {
            throw IllegalStateException(
                "Requested plugin `${pluginType}` is not registered with this Markdown instance")
        }
    }

    public override func getPlugins(): ArrayList<MarkdownPlugin> {
        return plugins
    }
}

/**
 * Builder for {@link Markdown}.
 * <p>
 * Please note that the order in which plugins are supplied is important as this order will be
 * used through the whole usage of built Markdown instance
 */
public interface MarkdownBuilder {
    func usePlugin(plugin: MarkdownPlugin): MarkdownBuilder

    func usePlugins(plugins: Iterable<MarkdownPlugin>): MarkdownBuilder

    /**
     * Control if small chunks of non-finished markdown sentences (for example, a single `*` Rune)
     * should be displayed/rendered as raw input instead of an empty string.
     * <p>
     * {@code true} by default, versions prior - {@code false}
     */
    func fallbackToRawInputWhenEmpty(fallbackToRawInputWhenEmpty: Bool): MarkdownBuilder

    func build(): Markdown
}

class MarkdownBuilderImpl <: MarkdownBuilder {
    private let plugins: ArrayList<MarkdownPlugin> = ArrayList<MarkdownPlugin>(3)

    private var _fallbackToRawInputWhenEmpty: Bool = true

    public override func usePlugin(plugin: MarkdownPlugin): MarkdownBuilder {
        this.plugins.append(plugin)
        return this
    }

    public override func usePlugins(plugins: Iterable<MarkdownPlugin>): MarkdownBuilder {
        for (plugin in plugins) {
            this.plugins.append(plugin)
        }
        return this
    }

    public override func fallbackToRawInputWhenEmpty(fallbackToRawInputWhenEmpty: Bool): MarkdownBuilder {
        this._fallbackToRawInputWhenEmpty = fallbackToRawInputWhenEmpty
        return this
    }

    public override func build(): Markdown {
        if (plugins.isEmpty()) {
            throw IllegalStateException("No plugins were added to this builder. Use #usePlugin method to add them")
        }

        // please note that this method must not modify supplied collection
        // if nothing should be done -> the same collection can be returned
        let plugins: ArrayList<MarkdownPlugin> = preparePlugins(this.plugins)

        let parserBuilder: ParserBuilder = ParserBuilder()
        parserBuilder.inlineParserFactory(InlineParserV2Factory()) // 使用v2版本的InlineParser
        let visitorBuilder: MarkdownVisitorBuilder = MarkdownVisitorBuilderImpl()

        for (plugin in plugins) {
            plugin.configureParser(parserBuilder)
            plugin.configureVisitor(visitorBuilder)
        }

        // do not reuse render-props (each render call should have own render-props)
        let visitorFactory: MarkdownVisitorFactory = createMarkdownVisitorFactory(visitorBuilder)

        return MarkdownImpl(
            parserBuilder.build(),
            visitorFactory,
            plugins,
            _fallbackToRawInputWhenEmpty
        )
    }

    private static func preparePlugins(plugins: ArrayList<MarkdownPlugin>): ArrayList<MarkdownPlugin> {
        return Registry(plugins).process()
    }
}
