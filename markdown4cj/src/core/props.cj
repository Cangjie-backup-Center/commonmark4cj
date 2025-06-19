/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.core

/**
 * Class to hold data in {@link RenderProps}. Represents a certain <em>property</em>.
 *
 * @param <T> represents the type that this instance holds
 * @see #of<T>(String)
 */
public class Prop<T> <: ToString & Hashable & Equatable<Prop<T>> {
    private let _name: String

    public init(name: String) {
        this._name = name
    }

    public func name(): String {
        return _name
    }

    // @Nullable
    public func get(props: RenderProps): ?T {
        return props.get(this)
    }

    public func get(props: RenderProps, defValue: T): T {
        return props.get(this, defValue)
    }

    public func require(props: RenderProps): T {
        return get(props).getOrThrow({=> NoneValueException(_name)})
    }

    public func set(props: RenderProps, value: ?T): Unit {
        props.set(this, value)
    }

    public func clear(props: RenderProps): Unit {
        props.clear(this)
    }

    public operator func ==(o: Prop<T>): Bool {
        return refEq(this, o) || _name == o._name
    }

    public operator func !=(o: Prop<T>): Bool {
        return !(this == o)
    }

    public override func hashCode(): Int {
        return _name.hashCode()
    }

    public override func toString(): String {
        return "Prop{name='${_name}\'}"
    }
}

public abstract class CoreProps {
    public static let LIST_ITEM_TYPE: Prop<ListItemType> = Prop<ListItemType>("list-item-type")

    public static let BULLET_LIST_ITEM_LEVEL: Prop<Int> = Prop<Int>("bullet-list-item-level")

    public static let ORDERED_LIST_ITEM_NUMBER: Prop<Int> = Prop<Int>("ordered-list-item-number")

    public static let HEADING_LEVEL: Prop<Int> = Prop<Int>("heading-level")

    public static let LINK_DESTINATION: Prop<String> = Prop<String>("link-destination")

    public static let PARAGRAPH_IS_IN_TIGHT_LIST: Prop<Bool> = Prop<Bool>("paragraph-is-in-tight-list")

    public static let CODE_BLOCK_INFO: Prop<String> = Prop<String>("code-block-info")

    private init() {}
}

public enum ListItemType {
    BULLET | ORDERED
}

public class RenderProps {
    private let values: Map<String, Any> = HashMap<String, Any>(3)

    // @Nullable
    public func get<T>(po: Prop<T>): ?T {
        //noinspection unchecked
        return if (let Some(v: T) <- values.get(po.name())) {
            v
        } else {
            None
        }
    }

    public func get<T>(po: Prop<T>, defValue: T): T {
        let value: ?Any = values.get(po.name())
        if (let Some(v: T) <- value) {
            //noinspection unchecked
            return v
        }
        return defValue
    }

    public func set<T>(po: Prop<T>, value: ?T): Unit {
        if (value.isNone()) {
            values.remove(po.name())
        } else {
            values.put(po.name(), value)
        }
    }

    public func clear<T>(po: Prop<T>): Unit {
        values.remove(po.name())
    }

    public func clearAll(): Unit {
        values.clear()
    }
}
