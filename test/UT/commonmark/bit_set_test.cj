package commonmark
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class BitSetTest {
    @TestCase
    func test1(): Unit {
        let bb = BitSet(5)
        let f = {
             => for (word in bb.words) {
                println(word.format("064b"))
            }
        }
        f()
        bb.set(0)
        bb.set(2)
        bb.set(4)
        f()
        println(bb.get(0))
        println(bb.get(1))
        println(bb.get(2))
        println(bb.get(3))
        println(bb.get(4))
        f()
        bb.set(63)
        f()
        bb.set(64)
        f()
    }

    @TestCase
    func bitset_01(): Unit {
        var bit = BitSet(0)
        @Assert(bit.get(0),false)
        bit.set(20)
        @Assert(bit.get(20),true)
    }

    @TestCase
    func bitset_02(): Unit {
        try {
            var bit = BitSet(-64)
            @Assert(bit.get(-9223372036854775808),false)
            bit.set(-9223372036854775808)
            @Assert(bit.get(-9223372036854775808),true)
        } catch (e: NegativeArraySizeException) {
            @Assert(e.toString(),"NegativeArraySizeException: size < 0: -64")
        }
    }

    @TestCase
    func bitset_03(): Unit {
        var bit = BitSet(2147483647)
        @Assert(bit.get(2147483647),false)
        bit.set(2147483647)
        @Assert(bit.get(2147483647),true)
    }

    @TestCase
    func bitset_04(): Unit {
        var bit = BitSet(21474836)
        @Assert(bit.get(21474836),false)
        bit.set(21474836)
        @Assert(bit.get(21474836),true)
    }

    @TestCase
    func bitset_05(): Unit {
        var bit = BitSet(21474836)
        @Assert(bit.get(21474836),false)
        bit.set(0)
        @Assert(bit.get(0),true)
    }

    @TestCase
    func bitset_06(): Unit {
        var bit = BitSet(0)
        @Assert(bit.get(21474836),false)
        bit.set(21474836)
        @Assert(bit.get(21474836),true)
    }

    @TestCase
    func bitset_07(): Unit {
        try {
            var bit = BitSet(0)
            @Assert(bit.get(21474836),false)
            bit.set(-21474836)
        } catch (e: IndexOutOfBoundsException) {
            @Assert(e.toString(),"IndexOutOfBoundsException: index < 0: -21474836")
        }
    }

    @TestCase
    func bitset_08(): Unit {
        var bit = BitSet(0)
        bit.set(21474836)
        @Assert(bit.get(21474836),true)
    }

    @TestCase
    func bitset_09(): Unit {
        var bit = BitSet(0)
        bit.set(21474836)
        @Assert(bit.get(0),false)
    }

    @TestCase
    func bitset_10(): Unit {
        var bit = BitSet(0)
        bit.set(21474836)
        @Assert(bit.get(26),false)
    }

    @TestCase
    func bitset_11(): Unit {
        var bit = BitSet(0)
        var bit1 = BitSet(0)
        bit1.set(1)
        @Assert(bit.get(1),false)
        bit.or(bit1)
        @Assert(bit.get(1),true)
    }
}

