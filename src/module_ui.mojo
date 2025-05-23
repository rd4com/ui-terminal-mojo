from .module_simple_backend import *
from time import sleep, monotonic
from sys.param_env import env_get_bool
from builtin._location import __call_location, _SourceLocation

#TODO: replace all with new XY struct
# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 👷 Todos                                                                  ║
# ╚════════════════════════════════════════════════════════════════════════════╝
#   - for widgets: `ui.states["MyCounter"] = 0`
#       (auto `.pop` when not used anymore)
#     this would make it not needed for users to have a Bool,
#     for the current_page of the paginated list widget for example
#   - upgrade widgets with ui.time_counter
# ╔════════════╗
# ║ 🏕️ Current ║ work on emojis
# ╚════════════╝
# OK: self.start_measuring() linear types
# ┌───────┐
# │ Ideas │
# └───────┘
#   - auto scrollbar when needed
#   - nested zones with scrollbar when needed
# ──────────────────────────────────────────────────────────────────────────────

# ╔══════════════╗
# ║ Help overlay ║
# ╚══════════════╝
# Explains how to navigate the ui,
# so that later, users of an app can get started from scratch.
@always_inline
fn help_overlay(mut ui:UI):
    alias overlay_help = (
        (String("exit"), Bg.blue, String("Esc")),
        (String("click"), Bg.blue, String("Enter")),
        (String("tabmenu"), Bg.blue, String("Tab")),
        (String("move cursor"), Bg.blue, String("Arrows")),
        (String("move cursor faster"), Bg.blue, String("Shift-Arrows")),
        (String("recenter the screen"), Bg.blue, String("Esc")),
    )
    Text(" Help overlay") | Bg.magenta | Fg.black in ui
    center[24](ui)
    if ui.help_overlay_is_opened:
        ui[-1].pos = XY(0, Int(ui.term_size[1]-len(overlay_help)-1))
    else:
        ui[-1].pos = XY(0, ui.term_size[1]-1)
    if ui[-1].hover():
        ui.help_overlay_is_opened ^= True

    @parameter
    for h in range(len(overlay_help)):
        Text(overlay_help[h][0]) in ui
        ui[-1].pos[0] = 0
        rjust[24](ui)
        tag(ui, overlay_help[h][1], overlay_help[h][2])

# ideas widget:
# - cursor magnet on previous element: `magnet(radius=4)`
# - cursor anchors to move there from click buttons
# - pause when cursor on it, rewind when cursor left

# ╔══════════╗
# ║ Aligning ║
# ╚══════════╝
fn center[width:Int](mut ui: UI):
    var element = Pointer(to=ui[-1])
    element[].data.value = element[].data.value.center(width, " ")

fn ljust[width:Int](mut ui: UI):
    var element = Pointer(to=ui[-1])
    element[].data.value = element[].data.value.ljust(width, " ")
fn rjust[width:Int](mut ui: UI):
    var element = Pointer(to=ui[-1])
    element[].data.value = element[].data.value.rjust(width, " ")


# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ Zone                                                                       ║
# ╚════════════════════════════════════════════════════════════════════════════╝

@value
struct Zone:
    #    parent idx  relative_x  relative_y  apply_to_nested_x/y    width height  data
    #[
    #   [0,          0,          0           0 (scroll)         24    10      ""   ],
    #   [0,          10,         0           0 (scroll)         3     1       "abc"],
    #      #example: ^, is in area of outer zone (parent_idx.width+pos)
    #   [0,          10,         1           0 (scroll)         3     1       "123"],
    #]
    # need something simpler, ⬆️ maybe for later
    var pos: XY
    var data: Text
    var ui_ptr: UnsafePointer[UI]
    fn __init__(out self):
        self.pos = XY(0, 0)
        self.data = Text()
        self.ui_ptr = __type_of(self.ui_ptr)()
    fn __ior__(mut self, other: Bg):
        self.data.bg = other.value
    fn __ior__(mut self, other: Fg):
        self.data.fg = other.value
    fn click(self)->Bool:
        if self.ui_ptr[].click:
            if self.hover():
                self.ui_ptr[].click = False
                return True
        return False
    fn hover(self)->Bool:
        return PositionAndDimensions(
            self.pos,
            XY(len(self.data.value), 1)
        ).__contains__(self.ui_ptr[].cursor)

#TODO: simplify to fn move_cursor_after(StartedMeasurment)
#      so that the function does the .stop_measuring() :thumbsup

@explicit_destroy()
struct StartedMeasurment[O:MutableOrigin]:
    var start_len: Int
    # the len of ui.zones when started measuring
    var ui_ptr: Pointer[UI, O]
    fn __init__(out self, ref [O] ui: UI):
        self.start_len = len(ui.zones)
        self.ui_ptr = Pointer(to=ui)
    fn stop_measuring(owned self, out ret: CompletedMeasurment[O]):
        ret = CompletedMeasurment(self^)
    fn peek_dimensions(self)->XY:
        """[width,height]."""
        return __calculate_width_heigh_from_to(
            self.ui_ptr[], self.start_len, len(self.ui_ptr[].zones)
        )
    fn start_border(mut self) -> Border[__origin_of(self)]:
        return Border[__origin_of(self)](self.ui_ptr[])


@explicit_destroy()
struct CompletedMeasurment[O:MutableOrigin]:
    var start_len: Int
    var stop_len: Int
    var ui_ptr: Pointer[UI, O]
    # the len of ui.zones when finished measuring
    fn __init__(out self, owned arg: StartedMeasurment[O]):
        self.start_len = arg.start_len
        self.stop_len = len(arg.ui_ptr[].zones)
        self.ui_ptr = arg.ui_ptr
        __disable_del(arg)
    fn get_dimensions(self)->XY:
        """[width,height]."""
        return __calculate_width_heigh_from_to(
            self.ui_ptr[], self.start_len, self.stop_len
        )
    fn hover(self)->Bool:
        if self.start_len>=len(self.ui_ptr[].zones):
            return False
        var dimensions = self.get_dimensions()
        var start_pos = self.ui_ptr[].zones[self.start_len].pos
        return PositionAndDimensions(start_pos, dimensions).__contains__(
            self.ui_ptr[].cursor
        )

    fn move_cursor_after(owned self):
        var dimensions = self.get_dimensions()
        if all(dimensions == XY(0,0)):
            self.ui_ptr[].next_position = self.ui_ptr[][-1].pos + XY(len(self.ui_ptr[][-1].data.value), 0)
            __disable_del(self)
            return
        self.ui_ptr[].next_position = self.ui_ptr[].zones[self.start_len].pos + XY(dimensions[0], 0)
        __disable_del(self)
    fn move_cursor_below(owned self):
        var dimensions = self.get_dimensions()
        if all(dimensions == XY(0,0)):
            self.ui_ptr[].next_position = self.ui_ptr[][-1].pos + XY(0, 1)
            __disable_del(self)
            return
        self.ui_ptr[].next_position = self.ui_ptr[].zones[self.start_len].pos + XY(0, dimensions[1])
        __disable_del(self)

@value
struct PositionAndDimensions:
    var start_pos: XY
    var dimensions: XY
    fn __contains__(self, pos: XY)->Bool:
        if any(pos<self.start_pos):
            return False
        if any(pos>=(self.start_pos+self.dimensions)):
            return False
        return True


# ╔══════════╗
# ║ Border   ║
# ╚══════════╝

# First implementation for creating bordering,
# seem to work but quite experimental:
@explicit_destroy
struct Border[M_O:MutableOrigin]:
    # M_O is the origin of an `StartedMeasurment`.
    # If `started_measurement^.stop_measuring()` is done before `self^.end_border()`,
    # there is an error of uninitialized Origin.
    # That way, the border is in the measurement!

    var first_border_index: Int
    #TODO: var ptr: Pointer[StartedMeasurment, Origin]
    # (So that still measuring when end_border is done)
    fn __init__(out self, mut ui: UI):
        Text(".") in ui
        self.first_border_index = len(ui.zones)-1
        ui.next_position = ui[-1].pos+1

    fn end_border[
        style_border:StyledBorder = StyleBorderSimple
    ](owned self, mut ui:UI, fg: Fg):
        # Very workaround, but need to make progress
        # var last_index = len(ui.zones)
        var tmp_size = __calculate_width_heigh_from_to(
                ui, self.first_border_index, len(ui.zones)
                )

        var last_border_x = Int(tmp_size[0]+1)
        ui.zones[self.first_border_index].data.value = "-"# * last_border_x
        ui.zones[self.first_border_index] |= fg
        ui.zones[self.first_border_index].data.replace_each_when_render = style_border.up_l #"┌"
        if last_border_x == 2:
            Text("-") | fg in ui
            ui[-1].pos = ui.zones[self.first_border_index].pos + XY(1, 0)
            ui[-1].data.replace_each_when_render = style_border.up_r # "┐"
        else:
            var horizontal_bars = last_border_x-2
            for i in range(horizontal_bars):
                Text("-") | fg in ui
                ui[-1].pos = ui.zones[self.first_border_index].pos + XY(1+i, 0)
                ui[-1].data.replace_each_when_render = style_border.h # "─"
            Text("-") | fg in ui
            ui[-1].pos = ui.zones[self.first_border_index].pos + XY(last_border_x-1, 0)
            ui[-1].data.replace_each_when_render = style_border.up_r # "┐"


        # var tmp_next_pos = ui.next_position
        # if not tmp_next_pos:
        #     tmp_next_pos = XY(ui[-1].x, ui[-1].y+2)

        for i in range(tmp_size[1]-1):
            Text("|") | fg in ui
            ui[-1].pos =ui.zones[self.first_border_index].pos + XY(0, i+1) 
            ui[-1].data.replace_each_when_render = style_border.v # "│"
            Text("|") | fg in ui
            ui[-1].pos =ui.zones[self.first_border_index].pos + XY(tmp_size[0], i+1) 
            ui[-1].data.replace_each_when_render = style_border.v # "│"

        Text("-") | fg in ui
        ui[-1].data.replace_each_when_render = style_border.b_l # "└"
        ui[-1].pos[0] =ui.zones[self.first_border_index].pos[0]
        var h_border_pos = ui[-1].pos[1]
        if last_border_x == 2:
            Text("-") | fg in ui
            ui[-1].pos = XY(ui.zones[self.first_border_index].pos[0]+1, h_border_pos)
            ui[-1].data.replace_each_when_render = style_border.b_r # "┘"
        else:
            var horizontal_bars = last_border_x-2
            for i in range(horizontal_bars):
                Text("-") | fg in ui
                ui[-1].pos = XY(ui.zones[self.first_border_index].pos[0]+1+i, h_border_pos)
                ui[-1].data.replace_each_when_render = style_border.h # "─"
            Text("-") | fg in ui
            ui[-1].pos = XY(ui.zones[self.first_border_index].pos[0]+last_border_x-1, h_border_pos)
            ui[-1].data.replace_each_when_render = style_border.b_r # "┘"

        # ui.next_position = tmp_next_pos

        __disable_del(self)

    # fn end_border[style:String=".",animate:Optional[Int]=None](owned self, mut ui:UI, fg: Fg):
    #     # var last_index = len(ui.zones)
    #     var tmp_measuring = ui.start_measuring()
    #     tmp_measuring.start_len = self.first_border_index
    #     var tmp_size = tmp_measuring.peek_dimensions()
    #     var stop_measuring = tmp_measuring^.stop_measuring()
    #     __disable_del stop_measuring
    #
    #     var last_border_x = Int(tmp_size[0]+1)
    #     ui.zones[self.first_border_index].data.value = style * last_border_x
    #     ui.zones[self.first_border_index] |= fg
    #
    #     var tmp_next_pos = ui.next_position
    #     if not tmp_next_pos:
    #         tmp_next_pos = XY(ui[-1].x, ui[-1].y+2)
    #
    #     for i in range(tmp_size[1]-1):
    #         @parameter
    #         if animate:
    #             spinner[animate.value()](ui)
    #             ui[-1]|=fg
    #         else:
    #             Text(style) | fg in ui
    #         ui[-1].x = ui.zones[self.first_border_index].x
    #         ui[-1].y = ui.zones[self.first_border_index].y+Int(i+1)
    #         @parameter
    #         if animate:
    #             spinner[animate.value()](ui)
    #             ui[-1]|=fg
    #         else:
    #             Text(style) | fg in ui
    #         ui[-1].x = ui.zones[self.first_border_index].x + Int(tmp_size[0])
    #         ui[-1].y = ui.zones[self.first_border_index].y+Int(i+1)
    #
    #     Text(style * last_border_x) | fg in ui
    #     ui[-1].x = ui.zones[self.first_border_index].x
    #
    #     ui.next_position = tmp_next_pos
    #
    #     __disable_del(self)

# Styles, need be more customizable
# (dynamically for animations)

trait StyledBorder:
    alias up_l: String
    alias up_r: String
    alias v: String
    alias h: String
    alias b_l: String
    alias b_r: String

struct StyleBorderSimple(StyledBorder):
    alias up_l = String("┌")
    alias up_r = String("┐")
    alias v = String("│")
    alias h = String("─")
    alias b_l = String("└")
    alias b_r = String("┘")
struct StyleBorderCurved(StyledBorder):
    alias up_l = String("╭")
    alias up_r = String("╮")
    alias v = String("│")
    alias h = String("─")
    alias b_l = String("╰")
    alias b_r = String("╯")
struct StyleBorderDouble(StyledBorder):
    alias up_l = String("╔")
    alias up_r = String("╗")
    alias v = String("║")
    alias h = String("═")
    alias b_l = String("╚")
    alias b_r = String("╝")


# ┌────────────────────────────────────────────────────────────────────────────┐
#      Not api: insertions of elements in the ui
fn __set_first_element(mut ui: UI, arg: Text):
    var tmp_zone = Zone()
    tmp_zone.data = arg
    tmp_zone.ui_ptr = UnsafePointer(to=ui)
    tmp_zone.pos = ui.scroll
    ui.zones.append(tmp_zone)

fn __insert_below(arg: Zone, owned other: Text):
    var new_zone = arg
    new_zone.data = other
    if arg.ui_ptr[].next_position:
        new_zone.pos = arg.ui_ptr[].next_position.value()
        arg.ui_ptr[].next_position = None
    else:
        new_zone.pos += XY(0, 1)
    arg.ui_ptr[].zones.append(new_zone^)
fn __calculate_width_heigh_from_to(
    ui: UI, start_len: Int, stop_len: Int
) -> XY:
    var smallest = XY(Int32.MAX, Int32.MAX)
    var largest = XY(Int32.MIN, Int32.MIN)
    if start_len == stop_len:
        return XY(0,0)

    var ptr = Pointer(to=ui.zones)
    for i in range(start_len,stop_len):
        var current = ptr[][i].pos
        smallest = (current < smallest).select(current, smallest)
        current += XY(len(ptr[][i].data.value), 0)
        largest = (current > largest).select(current, largest)
    return (largest-smallest)+XY(0, 1)
# └────────────────────────────────────────────────────────────────────────────┘

@value
struct DebugEntry:
    var origin: _SourceLocation
    var position: XY
    var value: String


alias XY = SIMD[DType.int32, 2]

struct UI:
    alias is_terminal_debug = env_get_bool["terminal_debug", False]()
    var terminal_debug: List[DebugEntry] 

    var term: term_type
    var term_size: XY
    var time_counter: TimeCounter
    var events: Events
    alias zones_type = List[Zone]
    var zones: Self.zones_type
    var cursor: XY
    var scroll: XY
    var next_position: Optional[XY]
    # events:
    var click: Bool
    var backspace: Bool
    var input_buffer: String
    # features:
    var feature_tab_menu: Bool
    var feature_help_overlay: Bool
    var help_overlay_is_opened: Bool
    var show_tab_menu: Bool
    var cursor_before_tab_menu: SIMD[DType.int32, 2]

    @deprecated("very experimental, please don't use in prod, please don't do I/O in the 60FPS loop")
    fn __init__(out self, show_pre_start_screen:Bool = True):

        self.terminal_debug = List[DebugEntry]()

        constrained[
            simdwidthof[DType.uint8]()>=16,
            "App currently need SIMD for events, at least 16 elements"
        ]()
        self.term = term_type()
        self.term.get_attr()
        var tmp_ = self.term
        tmp_.to_raw()

        self.time_counter = TimeCounter()

        self.events = Events()

        self.term_size = get_term_size()

        if show_pre_start_screen:
            print(
                term_type.clear_screen(),
                term_type.move_write_cusor_to(0,0),
                end=""
            )
            print("Term size:", self.term_size)
            print("  - resizing not supported yet")
            print("  - emojis partially supported (when measuring horizontally)")
            print("")
            print(
                "press ",
                term_type.start_colors(Fg.blue,Bg.default),
                "Enter", term_type.default_colors()," to start the app",
                flush=True, sep=""
            )
            var tmp_event = self.events.get_k()
            while not all(tmp_event == Keys.enter):
                tmp_event = self.events.get_k()
                self.time_counter.wait_at_least()
            var tmp_len = len(self.events.values)
            for _ in range(tmp_len):
                _ = self.events.values.pop_next()


        print("\x1B[?25l")

        self.zones = Self.zones_type()
        self.cursor = __type_of(self.cursor)(0)
        self.scroll = __type_of(self.cursor)(0)
        self.next_position = __type_of(self.cursor)(0)
        self.feature_tab_menu = False
        self.cursor_before_tab_menu = __type_of(self.cursor)(0)
        self.feature_help_overlay = True
        self.help_overlay_is_opened = True
        self.click = False
        self.backspace = False
        self.input_buffer = String("")
        self.show_tab_menu = False

    fn __del__(owned self):
        print("\x1B[?25h")
        _ = self.term.set_attr()

    fn __iter__(mut self)->FrameIterator[__origin_of(self)]:
        return FrameIterator(self)

    fn start_measuring(mut self) -> StartedMeasurment[__origin_of(self)]:
        return StartedMeasurment(self)

    @always_inline
    fn __contains__(mut self, arg: Text):
        #TODO: ui["Menu2"].hover()
        if len(self.zones):
            __insert_below(self[-1], arg)
        else:
            __set_first_element(self, arg)
        @parameter
        if self.is_terminal_debug:
            var tmp_ = Pointer(to=self[-1])
            self.terminal_debug.append(
                DebugEntry(
                    __call_location(), 
                    tmp_[].pos, 
                    tmp_[].data.value
                )
            )
    @always_inline
    fn append(mut self, arg: Text):
        # Design talk with Owen, for an additional different way to do things
        arg in self

    fn __getitem__(mut self, pos:Int=-1) ->ref[__origin_of(self.zones)]Zone:
        if pos < 0:
            var idx = len(self.zones)+pos
            if idx >= 0:
                return self.zones[idx]
        else:
            if pos < len(self.zones):
                return self.zones[pos]

        # if there is none, could add a new one here:
        #FIXME: created one if needed
        Text(String()) in self
        return self.zones[len(self.zones)-1]

    fn set_tab_menu[f:fn () capturing->None](mut self):
        if self.show_tab_menu:
            var tmp = self.scroll
            self.scroll = 0
            Text("TabMenu") | Bg.yellow | Fg.black in self
            center[16](self)
            f()
            #TODO: Integrate ui.start_measuring()
            var largest = Int32(0)
            for e in self.zones:
                var current = len(e[].data.value)+e[].pos[0]
                if current> largest: largest = current
            self.scroll = tmp
            self.next_position = self.scroll
            while self.next_position.value()[0]<largest:
                self.next_position.value()[0]+=1

    fn update(mut self, out ret: Bool):
        #TODO: create a buffer, and .clear() to not realloc
        self.next_position = None
        if self.feature_help_overlay == True:
            help_overlay(self)

        # does time.sleep pause events too ?
        self.time_counter.wait_at_least()

        # new screen:
        var res = term_type.clear_screen()
        res += term_type.default_colors()

        # check event here !
        ret = self.handle_event()

        # render ui
        for i in self.zones:
            # TODO debug_assert no overlaps!
            var x_pos = i[].pos[0]
            var y_pos = i[].pos[1]
            var _width = Int32(len(i[].data.value))
            var screen_width = self.term_size[0]
            var screen_height = self.term_size[1]
            var x_start = Int32(0)
            var x_end = _width
            if x_pos >= screen_width: continue
            if y_pos >= screen_height: continue
            if (x_pos+_width) < 0: continue
            if y_pos < 0: continue
            if not _width: continue

            if x_pos+_width >= screen_width:
                x_end += screen_width-(x_pos+_width)
            if x_pos < 0:
                x_start += abs(0-x_pos)
                i[].pos[0]=0

            res += term_type.move_write_cusor_to(Int(i[].pos[0]), Int(i[].pos[1]))
            res += term_type.start_colors(Fg(i[].data.fg), Bg(i[].data.bg))
            if i[].data.replace_each_when_render:
                var tmp_res_ = i[].data.value[Int(x_start):Int(x_end)]
                var _replace_with = i[].data.replace_each_when_render.value()
                var tmp_res2_ = String()
                for _ in range(len(tmp_res_)):
                    tmp_res2_ += _replace_with
                res += tmp_res2_
            else:
                res += i[].data.value[Int(x_start):Int(x_end)]

        # render cursor
        # TODO: self.cursor = Text("X", ..)
        var _cursor = String("X")# need better ?
        res += term_type.move_write_cusor_to(
            Int(self.cursor[0]), Int(self.cursor[1])
        )
        res += term_type.start_colors(Fg.default,Bg.magenta)
        res += _cursor

        # reset to default
        res += term_type.default_colors()
        res += term_type.move_write_cusor_to(0,0)
        print(res, flush=True)

        #clear ui buffer
        self.zones.clear()
        self.next_position = None

        @parameter
        if self.is_terminal_debug:
            self.terminal_debug.clear()

    fn handle_event(mut self) -> Bool:
        var ev = self.events.get_k()
        # print(ev)
        # sleep(1.0)
        # if any(ev): self.debug_last_event = ev

        self.click = False
        self.backspace = False


        var fast_nav = 4
        var is_fast_nav = False
        if all(ev==Keys.shift_arrow_u):
            self.cursor[1]-= fast_nav
            is_fast_nav=True
        elif all(ev==Keys.shift_arrow_d):
            self.cursor[1]+= fast_nav
            is_fast_nav=True
        elif all(ev==Keys.shift_arrow_r):
            self.cursor[0]+= fast_nav
            is_fast_nav=True
        elif all(ev==Keys.shift_arrow_l):
            self.cursor[0]-= fast_nav
            is_fast_nav=True
        elif all(ev==Keys.arrow_u):
            self.cursor[1]-= 1
        elif all(ev==Keys.arrow_d):
            self.cursor[1]+= 1
        elif all(ev==Keys.arrow_r):
            self.cursor[0]+= 1
        elif all(ev==Keys.arrow_l):
            self.cursor[0]-= 1


        #TODO limit scrolling to last widget
        #    (inifinite scrolling is great, but need a map lol)

        # scroll when cursor goes edge of screen
        var changed_value = XY(1 if not is_fast_nav else fast_nav)
        var check_below = self.cursor<XY(0)
        var check_above = self.cursor>=self.term_size
        if any(check_above.join(check_below)):
            self.cursor = check_above.select(self.term_size-1, self.cursor)
            self.scroll = check_above.select(self.scroll-changed_value, self.scroll)
            self.cursor = check_below.select(XY(0), self.cursor)
            self.scroll = check_below.select(self.scroll+changed_value, self.scroll)


        if all(ev==Keys.tab):
            if self.feature_tab_menu:
                self.show_tab_menu ^= True
                if self.show_tab_menu:
                    self.cursor_before_tab_menu = self.cursor
                    self.cursor = 0
                else:
                    self.cursor = self.cursor_before_tab_menu
        elif all(ev==Keys.esc):
            if any(self.scroll!=0):
                # if scroll is changed, reset it
                self.scroll = 0
            else:
                # exit app
                return False
        elif all(ev==Keys.enter):
            self.click = True
        elif all(ev==Keys.backspace):
            self.backspace = True # TODO set to self.key

        if self.help_overlay_is_opened:
            # no click on elements below the overlay:
            var cursor_in_overlay = False
            #TODO: Integrate ui.start_measuring
            for i in range(1,20):
                if "Help overlay" in self[-i].data.value:
                    if self[-i].hover():
                        cursor_in_overlay = True
                    break
                if self[-i].hover():
                    cursor_in_overlay = True
            if cursor_in_overlay:
                self.click = False

        if Keys.is_input(ev):
            self.input_buffer += chr(Int(ev[0]))

        return True

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ FrameIterator                                                              ║
# ╚════════════════════════════════════════════════════════════════════════════╝
@value
struct FrameIterator[O:MutableOrigin]:
    var ui_ptr: Pointer[UI, O]
    var last_iteration: Bool
    fn __init__(out self, ref[O]ui: UI):
        self.ui_ptr = Pointer(to=ui)
        self.last_iteration = False
    fn __iter__(owned self)->Self:
        return self^
    fn __has_next__(mut self, out ret:Bool):
        ret = self.ui_ptr[].update()
        if not ret:
            self.last_iteration = True
    fn __next__(self)->Int:
        return 1
    fn __del__(owned self):
        ...
        # if self.last_iteration:
        #     _ = self.ui_ptr[].term.set_attr()
        # (should work already when UI.__del__)



# ┌────────────────────────────────────────────────────────────────────────────┐
# │ Widgets                                                                    │
# └────────────────────────────────────────────────────────────────────────────┘
@always_inline
fn input_buffer[W:Writable, //, label:W](mut ui:UI,mut buffer: String, mut edit: Bool):
    Text(label, buffer) | Bg.red in ui
    # toggle edit mode on click
    if ui[-1].click():
        if edit == False:
            ui[-1] |= Bg.red
            # clear input buffer if was not empty
            # (start from now)
            ui.input_buffer = String()
        edit ^= True
    # quit edit mode when cursor out of widget:
    if not ui[-1].hover(): edit=False
    if edit:
        ui[-1] |= Bg.green
    # if edit mode, flush input_buffer
    if edit and ui.input_buffer:
        buffer+=ui.input_buffer
        ui.input_buffer = String()
    if edit and ui.backspace:
        #FIXME: no self._buffer.pop, need new method
        if len(buffer)>1:
            buffer = buffer[0:len(buffer)-1]
        else:
            buffer = String()

@always_inline
fn widget_paginate_list[
    W:Writable,
    T:Representable&Copyable&Movable,
    //,
    label:W,
    elements_per_page:Int = 4
](mut ui:UI, list: List[T], mut current_page: Int):
    #list mut ?
    #TODO: return selected, need struct
    if not list: return
    if current_page < 0: current_page = 0
    if (current_page*elements_per_page) >= len(list):
        current_page = 0
    Text(label) | Bg.red in ui
    var total_pages = len(list)//elements_per_page
    total_pages += Int((len(list)%elements_per_page)!=0)

    start = current_page*elements_per_page
    for i in range(start, start+elements_per_page):
        if i<len(list):
            Text(repr(list[i])) in ui
        else:
            Text("") in ui

    Text(String(current_page+1,"/",total_pages)) in ui
    Text("Next page") in ui
    if ui[-1].click():
        current_page += 1
    Text("Prev page") in ui
    if ui[-1].click():
        current_page -= 1

@always_inline
fn widget_collapsible_menu[
    T:Representable&Copyable&Movable,
    //,
    label: String= "Menu"
](
    mut ui: UI, elements: List[T], mut is_opened: Bool, mut selected: Int,
    out ret: Bool
):
    #label ? Menu
    var current = selected
    Text(label) | Bg.black | Fg.yellow in ui
    if ui[-1].click():
        is_opened ^= True

    if is_opened:
        for i in range(len(elements)):
            Text(repr(elements[i]))|Bg(40|(Int(selected==i)*2)) in ui
            if ui[-1].click():
                if i<len(elements):
                   selected = i
    if selected == current:
        return False
    return True


# slider
# [|----------------] #16 values ?
# [^----------------] #16 more values ?
fn widget_slider[
    label:String,
    theme:Fg = Fg.yellow,
    preview_value: Bool = False
](mut ui:UI, mut value: UInt8):
    var start_label_v_measuring = ui.start_measuring()
    var start_label_measuring = ui.start_measuring()
    Text(String(label,":")) | theme in ui
    start_label_measuring^.stop_measuring().move_cursor_after()
    String(value) in ui
    start_label_v_measuring^.stop_measuring().move_cursor_below()

    var widget_measurement = ui.start_measuring()
    var start_h_measurement = ui.start_measuring()
    Text("[") | theme in ui
    start_h_measurement^.stop_measuring().move_cursor_after()
    for i in range(16):
        start_h_measurement = ui.start_measuring()
        if i == Int(value):
            Text("|") | theme in ui
        else:
            "-" in ui
            if ui[-1].click():
                value = i
            @parameter
            if preview_value:
                if ui[-1].hover():
                    Text(i) | theme in ui
        start_h_measurement^.stop_measuring().move_cursor_after()
    Text("]") | theme in ui
    widget_measurement^.stop_measuring().move_cursor_below()

fn widget_value_selector[
    T:Copyable&Movable&Representable,
    //,
    label:String, theme:Fg = Fg.yellow
](
    mut ui:UI, mut selected: Int, values: List[T]
):
    selected = selected%len(values)
    if not len(values): return

    var start_label_v_measuring = ui.start_measuring()
    var start_label_measuring = ui.start_measuring()

    Text("<") | theme.to_bg() in ui
    if ui[-1].click():
        selected -= 1
        if selected < 0:
            selected = len(values)-1
            selected = selected%len(values)
    start_label_measuring^.stop_measuring().move_cursor_after()
    start_label_measuring = ui.start_measuring()
    "|" in ui
    start_label_measuring^.stop_measuring().move_cursor_after()
    start_label_measuring = ui.start_measuring()
    Text(">") | theme.to_bg() in ui
    if ui[-1].click():
        selected += 1
        selected = selected%len(values)
    start_label_measuring^.stop_measuring().move_cursor_after()
    start_label_measuring = ui.start_measuring()
    Text(String(" ",label)) | theme in ui
    start_label_measuring^.stop_measuring().move_cursor_after()
    repr(values[selected]) in ui
    start_label_v_measuring^.stop_measuring().move_cursor_below()

fn widget_selection_group[
    T:Copyable&Movable&Representable,
    //,
    label:String, theme:Fg = Fg.yellow
](mut ui:UI, values:List[T], mut selected: Int):
    selected = selected%len(values)
    if not len(values): return


    Text(String(label)) | theme in ui

    for v in range(len(values)):
        if v == selected:
            var start_label_measuring = ui.start_measuring()
            var start_v_measuring = ui.start_measuring()
            Text("[") | theme in ui
            start_label_measuring^.stop_measuring().move_cursor_after()
            start_label_measuring = ui.start_measuring()
            Text(repr(values[v])) in ui
            start_label_measuring^.stop_measuring().move_cursor_after()
            Text("]") | theme in ui
            start_v_measuring^.stop_measuring().move_cursor_below()
        else:
            Text(repr(values[v])) in ui
            if ui[-1].click():
                selected = v

fn widget_percent_bar[theme: Fg=Fg.green](mut ui: UI, value:Int):
    var current = value // 10
    # var rest = value%10
    var widget_measuring = ui.start_measuring()
    var start_measuring = ui.start_measuring()
    Text(value, "%")|theme in ui
    start_measuring^.stop_measuring().move_cursor_after()
    start_measuring = ui.start_measuring()
    " [" in ui
    start_measuring^.stop_measuring().move_cursor_after()
    for i in range(10):
        start_measuring = ui.start_measuring()
        if i < current: Text("#")|theme in ui
        elif i == current:
            spinner(ui)
        else: "." in ui
        start_measuring^.stop_measuring().move_cursor_after()
    "]" in ui
    widget_measuring^.stop_measuring().move_cursor_below()

fn widget_percent_bar_with_speed[theme: Fg=Fg.green](mut ui: UI, value:Int, speed_up_to_two: Int):
    """Percent bar: `[#####/.....]`.
    
    Args:
        ui: The ui value.
        value: `0` to `100` (percentage value).
        speed_up_to_two: The speed ( 0 <= speed <= 2).
    """
    var normalized_speed = (speed_up_to_two%3)
    if speed_up_to_two > 2: normalized_speed = 2
    var pos = ((monotonic()*normalized_speed*4) // (10**(9)))&3
    alias l = List[String]("-","\\","|","/")
    var current_spinner = l[pos]
    if speed_up_to_two == 0: current_spinner = "|"

    var current = value // 10
    # var rest = value%10
    var widget_measuring = ui.start_measuring()
    var start_measuring = ui.start_measuring()
    Text(value, "%")|theme in ui
    start_measuring^.stop_measuring().move_cursor_after()
    start_measuring = ui.start_measuring()
    " [" in ui
    start_measuring^.stop_measuring().move_cursor_after()
    for i in range(10):
        start_measuring = ui.start_measuring()
        if i < current: Text("#")|theme in ui
        elif i == current:
            current_spinner in ui
        else: "." in ui
        start_measuring^.stop_measuring().move_cursor_after()
    "]" in ui
    widget_measuring^.stop_measuring().move_cursor_below()

@value
struct Notification:
    var creation_time: UInt
    var auto_fade_second: UInt
    var value: String
    var theme: Fg
    var extend_fade_counter_on_hover: Bool
    fn __init__(out self, value: String, theme:Fg = Fg.default ,auto_fade_second: Int = 0):
        self.creation_time = perf_counter_ns()
        self.auto_fade_second = auto_fade_second
        self.value = value
        self.theme = theme
        self.extend_fade_counter_on_hover = False

fn widget_notification_area[
    theme:Fg = Fg.green,
](mut ui: UI, mut storage: List[Notification]):
    if storage:
        Text("Notifications:") | theme.to_bg() in ui
        tag(ui, Bg.blue, len(storage))
    else:
        return
    var current = perf_counter_ns()
    var to_del = List[Int]()
    for v in range(len(storage)):
        Text(storage[v].value) | storage[v].theme in ui

        var element_back = 0
        if storage[v].auto_fade_second:
            if (storage[v].creation_time+storage[v].auto_fade_second*1000000000)<=current:
                to_del.append(v)
            var remaining = (storage[v].creation_time+storage[v].auto_fade_second*1000000000)-current
            var tmp_time = String(Float64(remaining)/1000000000)
            if len(tmp_time) >= 4: tmp_time = tmp_time[:4]
            tag(ui,Bg.blue, tmp_time)
            element_back+=1
        if ui[(-1)-element_back].click():
            to_del.append(v)
        if ui[-1-element_back].hover():
            if storage[v].auto_fade_second and storage[v].extend_fade_counter_on_hover:
                storage[v].creation_time = current
            Text("^Click to close") | Bg.blue in ui
    if to_del:
        for v in reversed(to_del):
            _ = storage.pop(v[])

@value
struct WidgetPlotSIMDQueue:
    alias size = 16
    var values: SIMD[DType.uint8, Self.size]
    fn __init__(out self):
        self.values = __type_of(self.values)(0)
    fn append_3bit_value(mut self, value: UInt8):
        "Append a value (`0 <= value <= 7`)."
        self.values = self.values.shift_left[1]()
        self.values[Self.size-1] = value
    fn average_3bit(self)->Float32:
        "`reduce_add(values % 8)` and divide by `Self.size`."
        return Float32((self.values&7).reduce_add())/Float32(Self.size)


fn widget_plot(mut ui: UI, values: WidgetPlotSIMDQueue, theme:Fg = Fg.default):
    alias ValuesUI = List[String](
        "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"
    )
    var total_showed_values = WidgetPlotSIMDQueue.size
    var widget_measuring = ui.start_measuring()
    for i in range(total_showed_values):
        var start_measuring = ui.start_measuring()
        var current_value = values.values[i]
        Text(" ") | theme in ui
        ui[-1].data.replace_each_when_render = ValuesUI[current_value&7]
        if ui[-1].hover():
            Text(current_value&7) in ui
        start_measuring^.stop_measuring().move_cursor_after()
    widget_measuring^.stop_measuring().move_cursor_below()

fn widget_steps[theme:Fg=Fg.green, spacing:Int = 2](
    mut ui: UI,
    steps:List[String],
    current_step:UInt8
):
    """Complete if `current_step>=len(steps)`."""
    var start_measure_all_widget = ui.start_measuring()
    var idx = 0
    for s in steps:
        var step_measure = ui.start_measuring()
        Text(String(s[]), " "*spacing) in ui
        if idx == Int(current_step):
            ui[-1] |= theme
        step_measure^.stop_measuring().move_cursor_after()
        idx+=1
    start_measure_all_widget^.stop_measuring().move_cursor_below()
    start_measure_all_widget = ui.start_measuring()
    idx = 0
    for s in steps:
        var step_measure = ui.start_measuring()
        Text(String("-"*(spacing+len(s[])))) in ui
        if idx == Int(current_step):
            ui[-1] |= theme
        ui[-1].data.replace_each_when_render = String("─")
        "*" in ui
        ui[-1].pos[1] -= 1
        ui[-1].data.replace_each_when_render = String("•")
        if idx <= Int(current_step):
            ui[-1] |= theme
        step_measure^.stop_measuring().move_cursor_after()
        idx+=1
    if Int(current_step)>= len(steps):
        Text(" Complete!") | theme in ui

    start_measure_all_widget^.stop_measuring().move_cursor_below()

# TODO: need fix len for emojis and border (to move cursor by 1)
# fn with_border[fg:Fg=Fg(0),bg:Bg=Bg(0)](mut ui: UI, arg:String):
#     var title_len = len(arg)
#     Text(String("┌", "─"*title_len,"┐"))|fg|bg in ui
#     Text(String("│", arg,"│"))|fg|bg in ui
#     Text(String("└", "─"*title_len,"┘"))|fg|bg in ui
# fn _widget_connectivity(mut ui: UI, value:Int):
#     var _value = value
#     if _value > 8: _value = 8
#     if _value < 0: _value = 0
#     var color = Fg.red
#     if _value >= 3: color = Fg.yellow
#     if _value >= 6: color = Fg.green
#     var _res:String = " ▁▂▃▄▅▆▇█"
#     Text(_res[:_value*3+1])|color in ui

fn widget_checkbox[W:Writable](mut ui:UI, label:W, mut value: Bool):
    if value: Text(String(label,"✅")) in ui
    else: Text(String(label,"⬜")) in ui
    if ui[-1].click():
        value = not value

fn widget_inline_message_box(
    mut ui:UI,
    # label:W,
    mut value: Optional[String]
):
    var animation = List[String]("📫","📪")
    if value:
        var pos = ((monotonic()*2) // (10**(9)))%2
        Text(animation[pos]) in ui
        Text(value.value()) | Bg.blue in ui
        if ui[-1].click(): value = None
        if ui[-1].hover():
            Text("^Click to remove") | Bg.magenta  in ui
    else:
        Text(animation[1]) in ui

fn widget_color_picker[preview_hover:Bool = True](mut ui:UI, mut value: Fg):
    var values = SIMD[DType.uint8,16](
        39, 30, 31, 32, 33, 34, 35, 36, 37
    )
    var start_measuring = ui.start_measuring()
    for i in range(9):

        var start_measuring2 = ui.start_measuring()
        Text(" ") | Fg(values[i]) in ui
        if ui[-1].click():
            value.value = values[i]
        if value.value == values[i]:
            ui[-1].data.replace_each_when_render = String("█")
        else:
            ui[-1].data.replace_each_when_render = String("─")
        @parameter
        if preview_hover:
            if ui[-1].hover():
                start_measuring2^.stop_measuring().move_cursor_after()
                start_measuring2 = ui.start_measuring()
                Text("example") | Fg(values[i]) in ui
        start_measuring2^.stop_measuring().move_cursor_after()
    var stop_measuring = start_measuring^.stop_measuring()
    stop_measuring^.move_cursor_below()


fn widget_progress_bar_thin[theme:Fg=Fg.green, width:Int=20](mut ui:UI, percentage: UInt8):
    constrained[100 >= width >=1, "100 >= width >= 1"]()
    var start_measuring = ui.start_measuring()
    var smallest = Float64(100.0)/Float64(width)
    for i in range(1,width+1):
        var start_measuring2 = ui.start_measuring()
        "-" in ui
        ui[-1].data.replace_each_when_render = String("─")
        if (i*smallest)<=Int(percentage):
            if percentage!=0:
                ui[-1] |= theme
        start_measuring2^.stop_measuring().move_cursor_after()

    Text(String(" ", percentage, "%")) | theme in ui

    var stop_measuring = start_measuring^.stop_measuring()
    stop_measuring^.move_cursor_below()

fn animate_emojis[values: List[String]](mut ui: UI):
    constrained[len(values)>=1, "At least one emoji"]()
    var pos = ((monotonic()*len(values)) // (10**(9)))%len(values)
    Text(String(values[pos])) in ui

# ╔═════════╗
# ║ tooltip ║
# ╚═════════╝
fn tooltip[bg: Bg = Bg.magenta,fg:Fg =Fg.black, pos:Int=-1](mut ui:UI, arg:String):
    if ui[pos].hover():
        Text(arg) | bg | fg in ui

# ╔════════════╗
# ║ Animations ║
# ╚════════════╝
fn blink[speed:Int=9](mut ui:UI):
    constrained[speed >= 8, "speed >= 8"]()
    if (monotonic() // (10**speed))&1:
        swap(ui[-1].data.fg, ui[-1].data.bg)
        ui[-1].data.fg-=10
        ui[-1].data.bg+=10
fn shake[speed:Int=8](mut ui:UI):
    # need another system to be able to animate for x seconds
    constrained[speed >= 8, "speed >= 8"]()
    ui[-1].pos[0] += ((monotonic() // (10**speed))%3)-1

# ╔════════╗
# ║ Ticker ║
# ╚════════╝
fn widget_ticker[R:Representable&Movable&Copyable,//, speed:Int=9](mut ui: UI, inputs: List[R]):
    constrained[speed >= 8, "speed >= 8"]()
    var current_time2 = (monotonic() // (10**9))
    Text(repr(inputs[current_time2%len(inputs)])) | Bg.yellow | Fg.black in ui

# ╔══════════╗
# ║ Spinners ║
# ╚══════════╝
fn spinner[speed:Int=1, forward: Bool=True](mut ui:UI):
    constrained[speed<=8, "Spinner"]()
    var pos = ((monotonic()*speed*4) // (10**(9)))&3
    @parameter
    if not forward:
        pos^=3
    alias l = List[String]("-","\\","|","/")
    Text(l[pos]) in ui

fn spinner2[width:Int=16, style:String = ".", speed:Int=1](mut ui:UI):
    constrained[speed<=4, "Spinner2 speed >4"]()
    constrained[len(style)==1, "len(style)!=1"]()
    var pos = ((monotonic()*speed*width) // (10**(9)))%width
    var res = (style*pos).center(width, " ")
    Text(res) in ui

fn animate_simple_inline(mut ui:UI):
    var pos = ((monotonic()*2*4) // (10**(9)))&3
    alias l = "._|-"
    Text(l[pos]) in ui

fn animate_time[theme:Fg=Fg.default](
    mut ui: UI,
):
    alias values = InlineArray[String,12](
        "🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚","🕛"
    )
    Text(" ") | theme in ui
    ui[-1].data.replace_each_when_render = values[(((ui.time_counter.previous*12)//1000000000))%12]

# fn animate_cursor[theme:Fg=Fg.default](
#     mut ui: UI,
# ):
#     alias values = InlineArray[String,4](
#         "░","▒","▓","█",
#     )
#     Text(" ") | theme in ui
#     ui[-1].data.replace_each_when_render = values[(((ui.time_counter.previous*4)//1000000000))%4]

# ╔═════╗
# ║ Tag ║
# ╚═════╝
fn tag[W:Writable](mut ui:UI, bg: Bg, value: W):
    #TODO: improve so can add more than one
    Text(value) | bg in ui
    ui[-1].pos[0] = len(ui[-2].data.value)+1+ui[-2].pos[0]
    ui[-1].pos[1]-=1
    ui.next_position= ui[-2].pos + XY(0, 1)


# ╔═══════╗
# ║ Icons ║
# ╚═══════╝
fn icons_circle[theme:Fg=Fg.default](
    mut ui: UI,
    thick: Bool = False
):
    Text(" ") | theme in ui
    if thick:
        ui[-1].data.replace_each_when_render = String("🞈")
    else:
        ui[-1].data.replace_each_when_render = String("🞅")

fn icons_square[theme:Fg=Fg.default](
    mut ui: UI,
    thick: Bool = False
):
    Text(" ") | theme in ui
    if thick:
        ui[-1].data.replace_each_when_render = String("🞓")
    else:
        ui[-1].data.replace_each_when_render = String("🞐")

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ debug_pannel                                                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

fn debug_pannel(mut ui: UI):
    
    # example:
    # mojo run -I build -D terminal_debug=True examples/example_debug_pannel.mojo
    @parameter
    if not ui.is_terminal_debug:
        return
    
    #With current cursor position:
    var found: Bool = False
    var cursor_pos = ui.cursor
    var idx = 0
    #TODO: `ui.get_element_at_pos` or `ui.__getitem__(self, pos: XY)`
    for v in ui.zones:
        if cursor_pos[0] >= v[].pos[0]:
            if cursor_pos[0] < (v[].pos[0]+len(v[].data.value)):
                if cursor_pos[1] == v[].pos[1]:
                    found = True
                    break
        idx+=1

    if found:
        var debug_value = ui.terminal_debug[idx]
        all_screen2 = ui.start_measuring()
        b = all_screen2.start_border()
        Text("Debug pannel") | Bg.blue in ui
 
        Text(String("pos:", debug_value.position)) | Fg.blue in ui
        Text(debug_value.origin) | Bg.blue in ui
        Text("Value:") | Fg.magenta in ui
        Text(debug_value.value) | Fg.blue in ui
        var fg = Fg(ui.zones[idx].data.fg)
        var bg = Bg(ui.zones[idx].data.bg).to_fg()
        
        var tmp_measure = ui.start_measuring()
        var tmp_border = tmp_measure.start_border()
        Text("fg color:") in ui
        widget_color_picker(ui, fg)
        tmp_border^.end_border(ui, fg)
        tmp_measure^.stop_measuring().move_cursor_after()

        tmp_measure = ui.start_measuring()
        tmp_border = tmp_measure.start_border()
        Text("bg color:") in ui
        widget_color_picker(ui, bg)
        tmp_border^.end_border(ui, bg)
        tmp_measure^.stop_measuring().move_cursor_after()
        
        b^.end_border(ui, Fg.blue)
        all_screen2^.stop_measuring().move_cursor_below()

# ┌───────┐
# │ Ideas │
# └───────┘
# For later to create ui things with emojis too:
# │ ─ ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼
# → ↓ ↑ ←
# ╔ ╗ ╚ ╝═║
# ╭ ╮╰ ╯─│
# emojis
# todo, spinner: ▁ ▂ ▃ ▄ ▅ ▆ ▇ █
