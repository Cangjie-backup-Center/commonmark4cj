/**
 * Created on 009 25/6/9
 */
package ohos_app_cangjie_library

internal import commonmark4cj.commonmark.*
internal import commonmark4cj.commonmark.Node as MdNode
internal import commonmark4cj.commonmark.{Text as MdText, HtmlInline as MdHtmlInline, Image as MdImage, Code as MdCode, 
    LinkReferenceDefinition as MdLinkReferenceDefinition, Link as MdLink, StrongEmphasis as MdStrongEmphasis, Emphasis as MdEmphasis, 
    HtmlBlock as MdHtmlBlock, IndentedCodeBlock as MdIndentedCodeBlock, FencedCodeBlock as MdFencedCodeBlock, Heading as MdHeading, 
    ListBlock as MdListBlock, BulletList as MdBulletList, OrderedList as MdOrderedList}
internal import commonmark4cj.table.*
internal import commonmark4cj.strikethrough.*
internal import markdown.core.*
internal import markdown.plugin.*
internal import ohos.hilog.Hilog
internal import ohos.ark_interop.*
internal import std.collection.*
import ohos.ark_interop_macro.*

let PARSER = Parser.builder().extensions([TablesExtension.create()]).build()

extend Alignment {
    func toString(): String {
        match (this) {
            case LEFT => "LEFT"
            case CENTER => "CENTER"
            case RIGHT => "RIGHT"
        }
    }
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["parseIntoJsNode"] = runtime.function(parseIntoJsNode).toJSValue()
}
