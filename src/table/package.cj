/**
 * commonmark extension for GFM strikethrough using ~~ (GitHub Flavored Markdown)
 */
package table

from commonmark4cj import commonmark.*
from std import collection.{HashSet, HashMap, Map, ArrayList}
from std import reflect.{TypeInfo}
from std import unicode.{UnicodeExtension}

extend Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}

public type CharSequence = Array<Rune>
extend Array<T> where T <: Rune {
    func trim(): Array<T> {
        var (a, b) = (0, this.size - 1)
        while (a <= b) {
            if (this[a].isWhiteSpace()) {
                a++
            } else {
                break
            }
        }
        while (b >= a) {
            if (this[b].isWhiteSpace()) {
                b--
            } else {
                break
            }
        }
        this[a..=b]
    }

    func replace(old: T, new: T): Unit {
        for (i in 0..this.size) {
            if (this[i] == old) {
                this[i] = new
            }
        }
    }
}