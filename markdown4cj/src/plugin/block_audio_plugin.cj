/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package markdown.plugin

public class BlockAudioPlugin <: AbstractMarkdownPlugin {
    public func getClassType(): String {
        "BlockAudioPlugin"
    }

    public override func configureParser(builder: ParserBuilder): Unit {
        builder.postProcessor(BlockAudioProcessor())
    }
}

class BlockAudioProcessor <: PostProcessor {
    public func process(node: Node): Node {
        node.accept(BlockAudioVisitor())
        node
    }
}

func isAudio(destination: String): Bool {
    let i = destination.lastIndexOf(b'.') ?? return false
    return match (destination[i..]) {
        case '.mp3' | '.wav' | '.aac' | '.flac' | '.ogg' | '.m4a' | '.wma' | '.amr' => return true
        case _ => false
    }
}

class BlockAudioVisitor <: AbstractVisitor {
    public func visit(paragraph: Paragraph): Unit {
        var p = paragraph
        var current: ?Node = p.getFirstChild()
        while (let Some(n) <- current) {
            current = n.getNext()
            match (n) {
                case n: Image where isAudio(n.getDestination()) =>
                    let oldp = p
                    // 提取Audio
                    n.unlink()
                    let block = BlockAudio()
                    block.appendChild(n)
                    p.insertAfter(block)
                    // 分割后续paragraph.children
                    if (let Some(c) <- current) {
                        let newp = Paragraph()
                        var n1: ?Node = current
                        while (let Some(n11) <- n1) {
                            n1 = n11.getNext()
                            n11.unlink()
                            newp.appendChild(n11)
                        }
                        block.insertAfter(newp)
                        p = newp
                    }
                    // 清理空p
                    if (oldp.getFirstChild().isNone()) {
                        oldp.unlink()
                    }
                case _ => ()
            }
        }
    }
}

public class BlockAudio <: CustomBlock {
    public func getNodeType() {
        "BlockAudio"
    }
}
