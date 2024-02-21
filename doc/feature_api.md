## commonMark4cj 库

### 介绍



### 1 Node

前置条件：NA 

场景：markdown解析得到的节点树，不同类型节点为不同的Node子类

约束：NA

可靠性：NA

#### 1.1 通用Node

##### 1.1.1 主要接口

```cangjie
/**
 * 通用节点
 */
public abstract class Node <: ToString & Equatable<Node> {
	
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public open func accept(visitor: Visitor): Unit
	
	/*
     * 获取下一个节点
     * 返回值 ?Node - Option Node 下一个节点
     */
    public func getNext(): ?Node

	/*
     * 获取上一个节点
     * 返回值 ?Node - Option Node 上一个节点
     */
    public func getPrevious(): ?Node
	
	/*
     * 获取第一个孩子节点
     * 返回值 ?Node - Option Node 第一个孩子节点
     */
    public func getFirstChild(): ?Node
    
	/*
     * 获取最后一个孩子节点
     * 返回值 ?Node - Option Node 最后一个孩子节点
     */
    public func getLastChild(): ?Node
	/*
     * 获取父节点
     * 返回值 ?Node - Option Node 父节点
     */
    public open func getParent(): ?Node
	/*
     * 末尾添加子节点
     * 参数 Node - 子节点
     */
    public func appendChild(child: Node): Unit
    /*
     * 开头添加子节点
     * 参数 Node - 子节点
     */
    public func prependChild(child: Node): Unit
    /*
     * 断开连接
     */
    public func unlink(): Unit
    
    /*
     * 后插入一个兄弟节点
     * 参数 Node - 兄弟节点
     */
    public func insertAfter(sibling: Node): Unit
    /*
     * 前插入一个兄弟节点
     * 参数 Node - 兄弟节点
     */
    public func insertBefore(sibling: Node): Unit
	/*
     * toString
     * 返回值 String - toString
     */
    public open func toString(): String
	/*
     * 重写 == 
     * 参数 Node - 比较Node
     * 返回值 Bool - 是否相等
     */
    public operator func ==(other: Node): Bool
	/*
     * 重写 != 
     * 参数 Node - 比较Node
     * 返回值 Bool - 是否相等
     */
    public operator func !=(other: Node): Bool
}

/**
 * 文本节点
 */
public class Text <: Node & Equatable<Text> {
    public init(literal: String): Unit
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
	/*
     * 获取文本
     * 返回值 String - 文本
     */
    public func getLiteral(): String
   	/*
     * 设置文本
     * 参数 String - 文本
     */
    public func setLiteral(literal: String): Unit
	/*
     * 重写 == 
     * 参数 Text - 比较Text
     * 返回值 Bool - 是否相等
     */
    public operator func ==(other: Text): Bool
	/*
     * 重写 != 
     * 参数 Text - 比较Text
     * 返回值 Bool - 是否相等
     */
    public operator func !=(other: Text): Bool
}

/**
 * HtmlInline节点
 */
public class HtmlInline <: Node {
    public init(literal: String): Unit
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
  	/*
     * 获取文本
     * 返回值 String - 文本
     */
    public func getLiteral(): String
   	/*
     * 设置文本
     * 参数 String - 文本
     */
    public func setLiteral(literal: String): Unit
}

/**
 * CustomNode节点
 */
public abstract class CustomNode <: Node {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
}

/**
 * 图片节点
 */
public class Image <: Node {
	/*
     * 初始化
     * 参数 String - 图片地址链接
     * 参数 ?String - 标题
     */
    public init(destination: String, title: ?String)
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
    /*
     * 获取地址链接
     * 返回值 String - 地址链接
     */
    public func getDestination(): String
	/*
     * 设置地址链接
     * 参数 String - 地址链接
     */
    public func setDestination(destination: String): Unit
    /*
     * 获取标题
     * 返回值 ?String - 标题
     */
    public func getTitle(): ?String
	/*
     * 设置标题
     * 参数 String - 标题
     */
    public func setTitle(title: String): Unit
}

/**
 * Code节点
 */
public class Code <: Node {
    public init(literal: String): Unit
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
	/*
     * 获取文本
     * 返回值 String - 文本
     */
    public func getLiteral(): String
   	/*
     * 设置文本
     * 参数 String - 文本
     */
    public func setLiteral(literal: String): Unit
}

/**
 * HardLineBreak节点
 */
public class HardLineBreak <: Node {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
}

/**
 * SoftLineBreak节点
 */
public class SoftLineBreak <: Node {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
}

/**
 * LinkReferenceDefinition节点
 */
public class LinkReferenceDefinition <: Node {
	/*
     * 初始化
     */
    public init()
	/*
     * 添加操作行为
     * 参数 String - 链接引用的标签
     * 参数 String - 目标地址
     * 参数 String - 标题吗
     */
    public init(label: String, destination: String, title: String)
	/*
     * 获取链接引用的标签
     * 返回值 ?String - 链接引用的标签
     */
    public func getLabel(): ?String
	/*
     * 设置链接引用的标签
     * 参数 String - 链接引用的标签
     */
    public func setLabel(label: String): Unit
    /*
     * 获取目标地址
     * 返回值 ?String - 目标地址
     */
    public func getDestination(): ?String
	/*
     * 设置目标地址
     * 参数 String - 目标地址
     */
    public func setDestination(destination: String): Unit
    /*
     * 获取标题
     * 返回值 ?String - 标题
     */
    public func getTitle(): ?String
	/*
     * 设置标题
     * 参数 String - 标题
     */
    public func setTitle(title: String): Unit
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
}

/**
 * Link节点
 */
public class Link <: Node {
    public init(destination: String, title: ?String)
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
    /*
     * 获取目标地址
     * 返回值 String - 目标地址
     */
    public func getDestination(): String
	/*
     * 设置目标地址
     * 参数 String - 目标地址
     */
    public func setDestination(destination: String): Unit
    /*
     * 获取标题
     * 返回值 ?String - 标题
     */
    public func getTitle(): ?String
	/*
     * 设置标题
     * 参数 String - 标题
     */
    public func setTitle(title: String): Unit

}

/**
 * 分隔符接口
 */
public interface Delimited {
    /*
     * 获取开头分隔符
     * 返回值 ?String - 标题
     */
    func getOpeningDelimiter(): ?String
    /*
     * 获取结尾分隔符
     * 返回值 ?String - 标题
     */
    func getClosingDelimiter(): ?String
}

/**
 * StrongEmphasis节点
 */
public class StrongEmphasis <: Node & Delimited {
	/*
     * 初始化
     */
    public init(): Unit
	/*
     * 初始化
     * 参数 String - 分隔符
     */
    public init(delimiter: String): Unit
	/*
     * 设置分隔符
     * 参数 String - 分隔符
     */
    public func setDelimiter(delimiter: String): Unit
    /*
     * 获取开头分隔符
     * 返回值 ?String - 标题
     */
    public func getOpeningDelimiter(): ?String
    /*
     * 获取结尾分隔符
     * 返回值 ?String - 标题
     */
    public func getClosingDelimiter(): ?String
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
}

public class Emphasis <: Node & Delimited {
	/*
     * 初始化
     */
    public init()
	/*
     * 初始化
     * 参数 String - 分隔符
     */
    public init(delimiter: String)
	/*
     * 设置分隔符
     * 参数 String - 分隔符
     */
    public func setDelimiter(delimiter: String): Unit
    /*
     * 获取开头分隔符
     * 返回值 ?String - 标题
     */
    public func getOpeningDelimiter(): ?String
    /*
     * 获取结尾分隔符
     * 返回值 ?String - 标题
     */
    public func getClosingDelimiter(): ?String
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public override func accept(visitor: Visitor): Unit
}
```

##### 1.1.2 示例

```cangjie

```

执行结果如下：

```shell
[ PASSED ] CASE: testFeatureApi01
```

#### 1.2 Block系列节点
##### 1.2.1 主要接口
```cangjie
public abstract class Block <: Node {
	/*
     * 获取父节点
     * 返回值 ?Node - Option Node 父节点
     */
    public func getParent(): ?Node
	/*
     * 设置父节点
     * 参数 Node - 父节点
     */
    protected override func setParent(parent: Node): Unit
}

public class BlockQuote <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
}

public class HtmlBlock <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
	/*
     * 获取文本
     * 返回值 String - 文本
     */
    public func getLiteral(): String
   	/*
     * 设置文本
     * 参数 String - 文本
     */
    public func setLiteral(literal: String): Unit
}

public abstract class CustomBlock <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
}

public class ThematicBreak <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
}

public class Document <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
}

public class Paragraph <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
}

public class IndentedCodeBlock <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
	/*
     * 获取文本
     * 返回值 String - 文本
     */
    public func getLiteral(): String
   	/*
     * 设置文本
     * 参数 String - 文本
     */
    public func setLiteral(literal: String): Unit
}

public class FencedCodeBlock <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
	/*
     * 获取围栏字符 默认`
     * 返回值 Char - 围栏字符
     */
    public func getFenceChar(): Char
   	/*
     * 设置围栏字符
     * 参数 Char - 围栏字符
     */
    public func setFenceChar(fenceChar: Char): Unit
	/*
     * 获取围栏代码块长度 至少3
     * 返回值 Int64 - 围栏代码块长度
     */
    public func getFenceLength(): Int64
   	/*
     * 设置围栏代码块长度
     * 参数 Int64 - 围栏代码块长度
     */
    public func setFenceLength(fenceLength: Int64): Unit
	/*
     * 获取围栏与代码块的缩进量
     * 返回值 Int64 - 围栏与代码块的缩进量
     */
    public func getFenceIndent(): Int64
   	/*
     * 设置围栏与代码块的缩进量
     * 参数 Int64 - 围栏与代码块的缩进量
     */
    public func setFenceIndent(fenceIndent: Int64): Unit
	/*
     * 获取语言标识符
     * 返回值 ?String - 语言标识符
     */
    public func getInfo(): ?String
   	/*
     * 设置语言标识符
     * 参数 String - 语言标识符
     */
    public func setInfo(info: String): Unit
	/*
     * 获取文本
     * 返回值 String - 文本
     */
    public func getLiteral(): String
   	/*
     * 设置文本
     * 参数 String - 文本
     */
    public func setLiteral(literal: String): Unit
}

public class ListItem <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
}

public class Heading <: Block {
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
	/*
     * 获取标题级别
     * 返回值 Int64 - 标题级别
     */
    public func getLevel(): Int64
   	/*
     * 设置标题级别
     * 参数 Int64 - 标题级别
     */
    public func setLevel(level: Int64): Unit
}
/**
 * 列表块节点
 */
public abstract class ListBlock <: Block {
	/*
     * 获取表块是不是紧凑的
     * 返回值 Bool - 列表块是不是紧凑的
     */
    public func isTight(): Bool
   	/*
     * 设置列表块是不是紧凑的
     * 参数 Bool - 列表块是不是紧凑的
     */
    public func setTight(tight: Bool)
}
/**
 * 无序列表块节点
 */
public class BulletList <: ListBlock {
   	/*
     * 初始化
     * 参数 Char - 标记
     */
    public init(bulletMarker: Char): Unit
  	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
		
	/*
     * 获取标记
     * 返回值 Char - 标记
     */
    public func getBulletMarker(): Char
   	/*
     * 设置标记
     * 参数 Char - 标记
     */
    public func setBulletMarker(bulletMarker: Char): Unit
}
/**
 * 有序列表块节点
 */
public class OrderedList <: ListBlock {
   	/*
     * 初始化
     * 参数 Int64 - 起始数字
     * 参数 Char - 分隔符
     */
    public init(startNumber: Int64, delimiter: Char)
	/*
     * 添加操作行为
     * 参数 Visitor - 具体的操作行为
     */
    public func accept(visitor: Visitor): Unit
	/*
     * 获取起始数字
     * 返回值 Int64 - 起始数字
     */
    public func getStartNumber(): Int64
   	/*
     * 设置起始数字
     * 参数 Int64 - 起始数字
     */
    public func setStartNumber(startNumber: Int64): Unit
	/*
     * 获取分隔符
     * 返回值 Char - 分隔符
     */
    public func getDelimiter(): Char
   	/*
     * 设置分隔符
     * 参数 Char - 分隔符
     */
    public func setDelimiter(delimiter: Char): Unit
}
```

#### 1.3 Visitor系列节点

##### 1.2.1 主要接口

```cangjie
public interface Visitor {
    func visit(blockQuote: BlockQuote): Unit

    func visit(bulletList: BulletList): Unit

    func visit(code: Code): Unit

    func visit(document: Document): Unit

    func visit(emphasis: Emphasis): Unit

    func visit(fencedCodeBlock: FencedCodeBlock): Unit

    func visit(hardLineBreak: HardLineBreak): Unit

    func visit(heading: Heading): Unit

    func visit(thematicBreak: ThematicBreak): Unit

    func visit(htmlInline: HtmlInline): Unit

    func visit(htmlBlock: HtmlBlock): Unit

    func visit(image: Image): Unit

    func visit(indentedCodeBlock: IndentedCodeBlock): Unit

    func visit(link: Link): Unit

    func visit(listItem: ListItem): Unit

    func visit(orderedList: OrderedList): Unit

    func visit(paragraph: Paragraph): Unit

    func visit(softLineBreak: SoftLineBreak): Unit

    func visit(strongEmphasis: StrongEmphasis): Unit

    func visit(text: Text): Unit

    func visit(linkReferenceDefinition: LinkReferenceDefinition): Unit

    func visit(customBlock: CustomBlock): Unit

    func visit(customNode: CustomNode): Unit
}

public abstract class AbstractVisitor <: Visitor {
	/*
     * 处理渲染BlockQuote节点的行为
     * 参数 BlockQuote - BlockQuote节点
     */
    public open func visit(blockQuote: BlockQuote): Unit
	/*
     * 处理渲染BulletList节点的行为
     * 参数 BulletList - BulletList节点
     */
    public open func visit(bulletList: BulletList): Unit
  	/*
     * 处理渲染Code节点的行为
     * 参数 Code - Code节点
     */
    public open func visit(code: Code): Unit
	/*
     * 处理渲染Document节点的行为
     * 参数 Document - Document节点
     */
    public open func visit(document: Document): Unit
	/*
     * 处理渲染Emphasis节点的行为
     * 参数 Emphasis - Emphasis节点
     */
    public open func visit(emphasis: Emphasis): Unit
	/*
     * 处理渲染FencedCodeBlock节点的行为
     * 参数 FencedCodeBlock - FencedCodeBlock节点
     */
    public open func visit(fencedCodeBlock: FencedCodeBlock): Unit
	/*
     * 处理渲染HardLineBreak节点的行为
     * 参数 HardLineBreak - HardLineBreak节点
     */
    public open func visit(hardLineBreak: HardLineBreak): Unit
  	/*
     * 处理渲染Heading节点的行为
     * 参数 Heading - Heading节点
     */
    public open func visit(heading: Heading): Unit
	/*
     * 处理渲染ThematicBreak节点的行为
     * 参数 ThematicBreak - ThematicBreak节点
     */
    public open func visit(thematicBreak: ThematicBreak): Unit
  	/*
     * 处理渲染HtmlInline节点的行为
     * 参数 HtmlInline - HtmlInline节点
     */
    public open func visit(htmlInline: HtmlInline): Unit
	/*
     * 处理渲染HtmlBlock节点的行为
     * 参数 HtmlBlock - HtmlBlock节点
     */
    public open func visit(htmlBlock: HtmlBlock): Unit
	/*
     * 处理渲染Image节点的行为
     * 参数 Image - Image节点
     */
    public open func visit(image: Image): Unit
	/*
     * 处理渲染IndentedCodeBlock节点的行为
     * 参数 IndentedCodeBlock - IndentedCodeBlock节点
     */
    public open func visit(indentedCodeBlock: IndentedCodeBlock): Unit
	/*
     * 处理渲染Link节点的行为
     * 参数 Link - Link节点
     */
    public open func visit(link: Link): Unit
	/*
     * 处理渲染ListItem节点的行为
     * 参数 ListItem - ListItem节点
     */
    public open func visit(listItem: ListItem): Unit
	/*
     * 处理渲染OrderedList节点的行为
     * 参数 OrderedList - OrderedList节点
     */
    public open func visit(orderedList: OrderedList): Unit
  	/*
     * 处理渲染Paragraph节点的行为
     * 参数 Paragraph - Paragraph节点
     */
    public open func visit(paragraph: Paragraph): Unit
	/*
     * 处理渲染SoftLineBreak节点的行为
     * 参数 SoftLineBreak - SoftLineBreak节点
     */
    public open func visit(softLineBreak: SoftLineBreak): Unit
	/*
     * 处理渲染StrongEmphasis节点的行为
     * 参数 StrongEmphasis - StrongEmphasis节点
     */
    public open func visit(strongEmphasis: StrongEmphasis): Unit
  	/*
     * 处理渲染Text节点的行为
     * 参数 Text - Text节点
     */
    public open func visit(text: Text): Unit
	/*
     * 处理渲染LinkReferenceDefinition节点的行为
     * 参数 LinkReferenceDefinition - LinkReferenceDefinition节点
     */
    public open func visit(linkReferenceDefinition: LinkReferenceDefinition): Unit
	/*
     * 处理渲染CustomBlock节点的行为
     * 参数 CustomBlock - CustomBlock节点
     */
    public open func visit(customBlock: CustomBlock): Unit
	/*
     * 处理渲染CustomNode节点的行为
     * 参数 CustomNode - CustomNode节点
     */
    public open func visit(customNode: CustomNode): Unit
}
```

