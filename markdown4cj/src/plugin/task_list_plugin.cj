/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

public class TaskListItem <: ListItem {
    public static let TASK_DEPTH = "TaskDepth"
    static let typeInfo: String = "TaskListItem"
    private let isdone: Bool

    public init(isDone: Bool) {
        this.isdone = isDone
    }

    public func isDone(): Bool {
        return isdone
    }

    public func toString(): String {
        return "TaskListItem{isDone=${isdone}}"
    }

    public func getNodeType(): String {
        typeInfo
    }
}

public class TaskListPlugin <: AbstractMarkdownPlugin {
    public static func create(): TaskListPlugin {
        return TaskListPlugin(0, 0, 0)
    }

    public static func create(
        checkedFillColor: UInt32,
        normalOutlineColor: UInt32,
        checkMarkColor: UInt32
    ): TaskListPlugin {
        return TaskListPlugin(
            checkedFillColor,
            normalOutlineColor,
            checkMarkColor
        )
    }

    let checkedFillColor: UInt32
    let normalOutlineColor: UInt32
    let checkMarkColor: UInt32

    private init(
        checkedFillColor: UInt32,
        normalOutlineColor: UInt32,
        checkMarkColor: UInt32
    ) {
        this.checkedFillColor = checkedFillColor
        this.normalOutlineColor = normalOutlineColor
        this.checkMarkColor = checkMarkColor
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.postProcessor(TaskListPostProcessor())
    }

    public func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            TaskListItem.typeInfo,
            {
                visitor, taskListItem =>
                let view = buildView(taskListItem, true, needProps: true)
                let taskDepth = if (let Some(Some(dep: Int)) <- taskListItem
                    .getParent()?
                    .getView()
                    .props?
                    .get(TaskListItem.TASK_DEPTH)) {
                    dep + 1
                } else {
                    0
                }
                view.props?.add(TaskListItem.TASK_DEPTH, taskDepth)
                visitor.visitChildren(taskListItem)
            }
        )
    }

    public func getClassType(): String {
        "TaskListPlugin"
    }
}

class TaskListVisitor <: AbstractVisitor {
    private static let REGEX_TASK_LIST_ITEM: Regex = Regex(#"^\[[xX\s]\]\s+(.*)"#)

    public func visit(listItem: ListItem): Unit {
        // Takes first child and checks if it is Text (we are looking for exact `[xX\s]` without any formatting)
        // check if it is paragraph (can contain text)
        if (let Some(child: Paragraph) <- listItem.getFirstChild()) {
            if (let Some(textNode: Text) <- child.getFirstChild()) {
                let text: String = textNode.getLiteral()
                let matcher: Matcher = REGEX_TASK_LIST_ITEM.matcher(text)

                if (let Some(data) <- matcher.find()) {
                    let checked: Byte = text[1]
                    let isChecked: Bool = (checked == b'x') || (checked == b'X')

                    let taskListItem: TaskListItem = TaskListItem(isChecked)

                    let paragraph: Paragraph = Paragraph()

                    // insert before list item (directly before inside parent)
                    listItem.insertBefore(taskListItem)

                    // append the rest of matched text (can be empty)
                    let restMatchedText: String = if (data.groupNumber() == 1) {
                        let group2 = data.matchPosition(1)
                        text[group2.start..group2.end]
                    } else {
                        ""
                    }
                    if (restMatchedText.size != 0) {
                        paragraph.appendChild(Text(restMatchedText))
                    }

                    // move all the rest children (from the first paragraph)
                    ParserUtils.moveChildren(paragraph, textNode)

                    // append our created paragraph
                    taskListItem.appendChild(paragraph)

                    // move all the rest children from the listItem (further nested lists, etc)
                    ParserUtils.moveChildren(taskListItem, child)

                    // remove list item from node
                    listItem.unlink()

                    // visit taskListItem children
                    visitChildren(taskListItem)
                    return
                }
            }
        }
        visitChildren(listItem)
    }
}

// Hint taken from commonmark-ext-task-list-items artifact
class TaskListPostProcessor <: PostProcessor {
    public func process(node: Node): Node {
        let visitor: TaskListVisitor = TaskListVisitor()
        node.accept(visitor)
        return node
    }
}

public abstract class TaskListProps {
    public static let DONE: Prop<Bool> = Prop<Bool>("task-list-done")
    private init() {}
}
