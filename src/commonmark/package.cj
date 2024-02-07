/**
 * Core of commonmark (implementation of CommonMark for parsing markdown and rendering to HTML)
 */
package commonmark

from std import collection.{ArrayList, HashMap, HashSet, Map, EquatableCollection, Set, LinkedList}
from std import convert.{Parsable}
from std import fs.{File, OpenOption, Path, Directory}
from std import io.{StringReader, InputStream, IOException}
from std import os.{getEnv}
from std import reflect.{TypeInfo}
from std import regex.{Regex, Matcher, MatchData, RegexOption, Position}
from std import unicode.{UnicodeExtension}

extend Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}

let NULL_CHAR: Char = '\u{0}'
let EMPTY_STRING: String = ""
let EMPTY_MAP: Map<String, String> = HashMap()
