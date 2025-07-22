/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown_hybrid

import log.*

class MyLogger <: Logger {
    public override func close() {}
    public override func isClosed() {
        false
    }
    public override func log(record: LogRecord): Unit {
        Hilog.error(0, "mdebug", record.message)
    }
    public override func withAttrs(attrs: Array<Attr>) {
        this
    }
    public var _level: LogLevel = LogLevel.ALL
    public mut override prop level: LogLevel {
        get() {
            _level
        }
        set(v) {
            _level = v
        }
    }
}

let GLOBAL_LOGGER = {
    =>
    let l = MyLogger()
    setGlobalLogger(l)
    l
}()
