/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.core

/**
 * @see #configure(Registry)
 */
// public interface Registry {
//     func require(plugin: String): MarkdownPlugin

//     func require(plugin: String, action: Action): Unit
// }

public class Registry {
    private let origin: ArrayList<MarkdownPlugin>
    private let plugins: ArrayList<MarkdownPlugin>
    private let pending: HashSet<MarkdownPlugin>

    init(origin: ArrayList<MarkdownPlugin>) {
        this.origin = origin
        this.plugins = ArrayList<MarkdownPlugin>(origin.size)
        this.pending = HashSet<MarkdownPlugin>(3)
    }

    public func require<T>(classType: String): T where T <: MarkdownPlugin {
        return (get(classType) as T)()
    }

    public func require<T>(classType: String, action: Action): Unit where T <: MarkdownPlugin {
        action(get(classType))
    }

    func process(): ArrayList<MarkdownPlugin> {
        for (plugin in origin) {
            configure(plugin)
        }
        return plugins
    }

    private func configure(plugin: MarkdownPlugin): Unit {

        // important -> check if it's in plugins
        //  if it is -> no need to configure (already configured)

        if (!plugins.contains(plugin)) {
            if (pending.contains(plugin)) {
                throw IllegalStateException("Cyclic dependency chain found: ${pending}")
            }

            // start tracking plugins that are pending for configuration
            pending.add(plugin)

            plugin.configure(this)

            // stop pending tracking
            pending.remove(plugin)

            // check again if it's included (a child might've configured it already)
            // add to out-collection if not already present
            // this is a bit different from `find` method as it does check for exact instance
            // and not a sub-type
            if (!plugins.contains(plugin)) {
                // core-plugin must always be the first one (if it's present)
                if (plugin is CorePlugin) {
                    plugins.add(plugin,at:0)
                } else {
                    plugins.add(plugin)
                }
            }
        }
    }

    private func get(pluginType: String): MarkdownPlugin {

        // check if present already in plugins
        // find in origin, if not found -> throw, else add to out-plugins

        var plugin: ?MarkdownPlugin = find(plugins, pluginType)

        if (plugin.isNone()) {
            plugin = find(origin, pluginType)

            if (plugin.isNone()) {
                throw IllegalStateException("Requested plugin is not added: ${pluginType}, plugins: ${origin}")
            }

            configure(plugin())
        }

        return plugin()
    }

    // @Nullable
    private static func find(plugins: ArrayList<MarkdownPlugin>, pluginType: String): ?MarkdownPlugin {
        for (plugin in plugins) {
            if (pluginType == plugin.getClassType()) {
                //noinspection unchecked
                return plugin
            }
        }
        return None
    }
}
