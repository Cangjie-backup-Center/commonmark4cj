/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package markdown.plugin

/**
 * A single key + value attribute. (Only used for presentation.)
 */
public class Attribute <: Hashable & Equatable<Attribute> & ToString {
    private var key: String

    private var valValue: ?String

    // used to update the holding Attributes when the key / value is changed via this interface
    var parent: ?Attributes

    /**
     * Create a new attribute from unencoded (raw) key and value.
     *
     * @param key attribute key; case is preserved.
     * @param value attribute value (may be null)
     */
    public init(key: String, value: ?String) {
        this(key, value, None)
    }

    /**
     * Create a new attribute from unencoded (raw) key and value.
     *
     * @param key attribute key; case is preserved.
     * @param val attribute value (may be null)
     * @param parent the containing Attributes (this Attribute is not automatically added to said Attributes)
     */
    public init(key: String, val: ?String, parent: ?Attributes) {
        var keyTrim: String = key.strip()

        // trimming could potentially make empty, so validate here
        Validate.notEmpty(keyTrim)
        this.key = keyTrim
        this.valValue = val
        this.parent = parent
    }

    /**
     * Get the attribute key.
     *
     * @return the attribute key
     */
    public func getKey(): String {
        return key
    }

    /**
     * Get the attribute value. Will return an empty string if the value is not set.
     *
     * @return the attribute value
     */
    public func getValue(): String {
        return Attributes.checkNotNull(valValue)
    }

    /**
     * Set the attribute key; case is preserved.
     *
     * @param key the new key; must not be null
     */
    public func setKey(key: String): Unit {
        var keyTrim: String = key.strip()

        // trimming could potentially make empty, so validate here
        Validate.notEmpty(keyTrim)
        if (parent != None) {
            var i: Int64 = parent().indexOfKey(this.key)
            if (i != Attributes.NotFound) {
                parent().keys[i] = keyTrim
            }
        }
        this.key = keyTrim
    }

    /**
     * Set the attribute value.
     *
     * @param val the new attribute value; may be null (to set an enabled boolean attribute)
     * @return the previous value (if was null; an empty string)
     */
    public func setValue(val: ?String): String {
        var oldVal: ?String = this.valValue
        if (parent != None) {
            var i: Int64 = parent().indexOfKey(this.key)
            if (i != Attributes.NotFound) {
                // trust the container more
                oldVal = parent().get(this.key)
                match (val) {
                    case None => parent().vals[i] = None
                    case Some(v) => parent().vals[i] = v
                }
            }
        }
        this.valValue = val
        return Attributes.checkNotNull(oldVal)
    }

    public func toString(): String {
        return "${key}=${valValue}"
    }

    public func clone(): Attribute {
        return match (this.parent) {
            case None => Attribute(this.key, this.valValue, None)
            case Some(v) => Attribute(this.key, this.valValue, v.clone())
        }
    }

    @OverflowWrapping
    public func hashCode(): Int64 {
        // note parent not considered
        return match (valValue) {
            case None => 31 * key.hashCode()
            case Some(v) => 31 * key.hashCode() + v.hashCode()
        }
    }

    public operator func !=(that: Attribute): Bool {
        return !(this == that)
    }

    public operator func ==(that: Attribute): Bool {
        if (refEq(this, that)) {
            return true
        }
        if (key != that.key) {
            return false
        }
        return valValue == that.valValue
    }
}
