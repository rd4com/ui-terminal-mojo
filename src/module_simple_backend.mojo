from time import sleep
from time import perf_counter_ns
from sys import external_call
from sys.ffi import c_short, c_int, c_uint, c_char, c_long
from sys import os_is_macos
from sys import sizeof
from memory import UnsafePointer
from utils import StaticTuple
from simdqueue import *

@value
struct term_type:
    alias NCCS = 20 if os_is_macos() else 32
    var input: c_uint
    var output: c_uint
    var ctrl_f: c_uint
    var local_f: c_uint
    var c_l: StaticTuple[c_char, Int(not os_is_macos())]
    var specials: StaticTuple[UInt8, Self.NCCS]
    var speed_a: c_uint
    var speed_b: c_uint

    alias ECHO:c_uint = 8
    alias ICANNON:c_uint = 256 if os_is_macos() else 2
    alias VTIME:Int = 5 if not os_is_macos() else 17
    alias VMIN:Int = 6 if not os_is_macos() else 16

    fn __init__(out self):
        self.input = 0
        self.output = 0
        self.ctrl_f = 0
        self.local_f = 0
        self.c_l = __type_of(self.c_l)()
        @parameter
        if __type_of(self.c_l).size:
            self.c_l[0] = 0
        self.specials = __type_of(self.specials)()
        @parameter
        for n in range(Self.NCCS):
            self.specials[n] = 0
        self.speed_a = 0
        self.speed_b = 0

    fn get_attr(mut self):
        _ = external_call["tcgetattr", c_int, c_int, UnsafePointer[term_type]](0, UnsafePointer(to=self))
    fn set_attr(self):
        _ = external_call["tcsetattr", c_int, c_int,c_int, UnsafePointer[term_type]](0, 2, UnsafePointer(to=self))

    fn echo_off(mut self):
        self.local_f &= ~Self.ECHO
    fn echo_on(mut self):
        self.local_f |= Self.ECHO
    fn icanon_off(mut self):
        self.local_f &= ~Self.ICANNON
    fn icanon_on(mut self):
        self.local_f |= Self.ICANNON
    fn set_vtime(mut self):
        self.specials[Self.VMIN] = 0
        self.specials[Self.VTIME] = 0
    fn to_raw(mut self):
        self.echo_off()
        self.icanon_off()
        self.set_vtime()
        self.set_attr()

    @staticmethod
    fn move_write_cusor_to(x: Int, y: Int)->String:
        return String("\x1B[",y+1,";",x+1,"H")
    @staticmethod
    fn clear_screen()->String:
        return String("\x1B[2J")
    @staticmethod
    fn default_colors()->String:
        return String("\x1B[39;49m")
    @staticmethod
    fn start_colors(fg:Fg, bg:Bg, out ret:String):
        ret = String("\x1B[",fg.value,";",bg.value,"m")


struct Keys:
    alias storage_type = SIMD[DType.uint8, 8]

    alias backspace = Self.storage_type(127, 0, 0, 0, 0, 0, 0, 0)
    alias tab = Self.storage_type(9, 0, 0, 0, 0, 0, 0, 0)
    alias enter = Self.storage_type(10, 0, 0, 0, 0, 0, 0, 0)
    alias esc = Self.storage_type(27, 0, 0, 0, 0, 0, 0, 0)
    alias arrow_l = Self.storage_type(27, 91, 68, 0, 0, 0, 0, 0)
    alias arrow_r = Self.storage_type(27, 91, 67, 0, 0, 0, 0, 0)
    alias arrow_u = Self.storage_type(27, 91, 65, 0, 0, 0, 0, 0)
    alias arrow_d = Self.storage_type(27, 91, 66, 0, 0, 0, 0, 0)
    alias shift_arrow_l = Self.storage_type(27, 91, 49, 59, 50, 68, 0, 0)
    alias shift_arrow_r = Self.storage_type(27, 91, 49, 59, 50, 67, 0, 0)
    alias shift_arrow_u = Self.storage_type(27, 91, 49, 59, 50,65, 0, 0)
    alias shift_arrow_d = Self.storage_type(27, 91, 49, 59, 50,66, 0, 0)

    @staticmethod
    fn is_input(arg: Self.storage_type)->Bool:
        return (
            ((arg==0).cast[DType.uint8]().reduce_add() == (Self.storage_type.size -1))
            and (arg[0] >= 32)
            and (arg[0] < 127)
        )



@value
struct Events:
    var values: QueueSIMD[DType.uint8]
    fn __init__(out self):
        self.values = __type_of(self.values)()
    fn get_k(mut self, out ret: SIMD[DType.uint8, 8]):
        # read 8
        # append to self.list
        # return list[0], or ->n if 27
        var x = __type_of(ret)(0)
        var ok = external_call["read", c_int, c_int, UnsafePointer[__type_of(x)], c_int](
            0, UnsafePointer(to=x), x.size
        )
        if ok:
            for i in range(ok):
                self.values.append(x[Int(i)])
        if not self.values:
            return 0

        ret = 0
        var current = 0
        ret[current] = self.values.pop_next()
        current+=1
        if ret[0] != 27: return
        while self.values and self.values.peek_next() != 27:
            ret[current] = self.values.pop_next()
            current +=1
            if current == ret.size:
                return

fn get_term_size(out ret:SIMD[DType.uint8, 2]):
    try:
        # ask size:
        print("\033[18t")
        var x = SIMD[DType.uint8, 16](0)
        var done = False
        # wait for size:
        while not done:
            ok = external_call["read", c_int, c_int, UnsafePointer[__type_of(x)], c_int](
                0, UnsafePointer(to=x), x.size
            )
            if ok>0: done = True
        # starts with [27, 91, 56, 59] and end with 116
        var res = String()
        for e in range(4,16):
            if x[e]!=0 and x[e]!=116:
                res += chr(Int(x[e]))
        var res2 = res.split(";")
        if len(res2)!=2: return 0
        return __type_of(ret)(Int(res2[0]), Int(res2[1])).rotate_left[1]()
    except e: ...
    return 0


struct TimeCounter:
    alias nanos_in_one_sec:UInt = 1000000000
    var previous: UInt
    # var difference: UInt # for adjust waiting too long
    fn __init__(out self):
        self.previous = perf_counter_ns()
    fn wait_at_least(mut self, nanos: UInt= Self.nanos_in_one_sec//60):
        var current = perf_counter_ns()
        if (current-self.previous)<nanos:
            var in_sec = (Float64(nanos)-Float64(current-self.previous))/Float64(Self.nanos_in_one_sec)
            sleep(in_sec)
            self.previous = perf_counter_ns()
        else:
            self.previous = current

@value
struct Fg:
    alias default = Self(39)
    alias black = Self(30)
    alias red = Self(31)
    alias green = Self(32)
    alias yellow = Self(33)
    alias blue = Self(34)
    alias magenta = Self(35)
    alias cyan = Self(36)
    alias white = Self(37)
    var value: UInt8
    fn __init__(out self): self = Self.default
    fn to_bg(self)->Bg:
        return Bg(self.value+10)

@value
struct Bg:
    alias default = Self(49)
    alias black = Self(40)
    alias red = Self(41)
    alias green = Self(42)
    alias yellow = Self(43)
    alias blue = Self(44)
    alias magenta = Self(45)
    alias cyan = Self(46)
    alias white = Self(47)
    var value: UInt8
    fn __init__(out self): self = Self.default
    fn to_fg(self)->Fg:
        return Fg(self.value-10)

@value
struct Text:
    var value: String
    var fg: UInt8
    var bg: UInt8
    var replace_each_when_render: Optional[String]

    fn __init__(out self):
        self.fg=Fg.default.value
        self.bg=Bg.default.value
        self.value = String(" ")
        self.replace_each_when_render = None
    @implicit
    fn __init__(out self, value: StringLiteral):
        self.fg=Fg.default.value
        self.bg=Bg.default.value
        self.value = value
        self.replace_each_when_render = None
    @implicit
    fn __init__(out self, value: String):
        self.fg=Fg.default.value
        self.bg=Bg.default.value
        self.value = value
        self.replace_each_when_render = None
    fn __init__[*W: Writable](out self, *args: *W):
        self.value = String(args)
        self.fg=Fg.default.value
        self.bg=Bg.default.value
        self.replace_each_when_render = None
    fn __or__(self, other: Bg) -> Text:
        return Text(self.value, self.fg, other.value, None)

    fn __or__(self, other: Fg) -> Text:
        return Text(self.value, other.value, self.bg, None)

    fn __ior__(mut self, other: Bg):
        self.bg =other.value

    fn __ior__(mut self, other: Fg):
        self.fg =other.value
    fn write_to[W:Writer](self, mut writer: W):
        writer.write(self.value)
