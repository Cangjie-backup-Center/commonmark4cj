/**
 * Created on 2026/2/2
 */
package commonmark_hybrid

import std.regex.{Regex, RegexFlag}
import ohos.ark_interop.*
import ohos.hilog.*

public func splitTextToArr(context: JSContext, callInfo: JSCallInfo): JSValue {
    let pattern = callInfo[0].toString(context)
    let input = callInfo[1].toString(context)

    let all = Regex(pattern, Unicode).findAll(input)
    let result = Array<String>(all.size, {i => all[i].matchString()})
    let resultArray = Array<JSValue>(result.size, {i => context.string(result[i]).toJSValue()})
    return context.array(resultArray).toJSValue()
}