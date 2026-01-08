package commonmark_hybrid

internal import ohos.ark_interop.*

func testCJ(runtime: JSContext, callInfo: JSCallInfo): JSValue {
    let result = "Hello ${callInfo[0].toString()}"
    runtime.string(result).toJSValue()
}

//let EXPORT_MODULE1 = JSModule.registerModule {
//    runtime, exports => exports["testCJ"] = runtime.function(testCJ).toJSValue()
//}
