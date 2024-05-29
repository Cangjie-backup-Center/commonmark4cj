/**
 * commonmark extension for GFM strikethrough using ~~ (GitHub Flavored Markdown)
 */
package strikethrough

from commonmark4cj import commonmark.*
from std import collection.{HashSet, HashMap, Map}

extend Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}
