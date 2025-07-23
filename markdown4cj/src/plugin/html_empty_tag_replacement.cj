/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
package markdown.plugin

/**
 * This class will be used to append some text to output in order to
 * apply a Span for this tag. Please note that this class will be used for
 * _void_ tags and tags that are self-closed (even if HTML spec doesn\'t specify
 * a tag as self-closed). This is due to the fact that underlying parser does not
 * validate context and does not check if a tag is correctly used. Plus it will be
 * used for tags without content, for example: {@code <my-custom-element></my-custom-element>}
 */
public class HtmlEmptyTagReplacement {
    public static func create(): HtmlEmptyTagReplacement {
        return HtmlEmptyTagReplacement()
    }

    private static let IMG_REPLACEMENT = "\u{FFFC}"

    private static let IFRAME_REPLACEMENT = "\u{00a0}" // non-breakable space

    /**
     * @return replacement for supplied startTag or null if no replacement should occur (which will
     * lead to `Inline` tag have start &amp; end the same value, thus not applicable for applying a Span)
     */
    public func replace(tag: HtmlTag): ?String {
        let replacement: ?String
        let name = tag.name()
        if ("br" == name) {
            replacement = "\n"
        } else if ("img" == name) {
            let alt = tag.attributes().get("alt")
            if ((alt?.size ?? 0) == 0) {
                replacement = IMG_REPLACEMENT
            } else {
                replacement = alt
            }
        } else if ("iframe" == name) {
            replacement = IFRAME_REPLACEMENT
        } else {
            replacement = None
        }
        return replacement
    }
}
