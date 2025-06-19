/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package markdown.plugin

public class UncheckedIOException <: Exception {
    init(cause: IOException) {
        super(cause.message)
    }

    init(message: String) {
        super(message)
    }

    public override func getClassName(): String {
        "UncheckedIOException"
    }
}
