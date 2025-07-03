# This is an example, there could be bugs,
# Please don't use this with no checks !

from `ui-terminal-mojo` import *
from pathlib import cwd, Path
from os import stat_result

@fieldwise_init
struct DirView(Movable&Copyable):
    var path: Path
    var content: List[DirEntry]
    fn __init__(out self, p: Path):
        self.path = p
        self.content = __type_of(self.content)()
        try: 
            var tmp = p.listdir()
            for e in tmp:
                var entry = DirEntry(
                        String(e), 
                        e, 
                        (p/e).is_dir(),
                        (p/e).stat()
                )
                self.content.append(entry^)
        except e: ...
    fn refresh(mut self, out success: Bool):
        if self.path.exists() and self.path.is_dir():
            self = Self(self.path)
            return True
        return False

@fieldwise_init
struct DirEntry(Movable&Copyable):
    var name: String
    var path: Path
    var is_dir: Bool
    var stats: stat_result

def main():
    var ui = UI()
    var start_dir = List(DirView(cwd()))

    var size_values = List[String]("None", "B", "Kb", "Mb")
    var size_selected = 0
    var show_perm = False

    var sort_values = List[String]("Access time", "Modification time", "Creation time", "Size")
    var sort_selected = 0
    @parameter
    fn f_sort(a:DirEntry, b:DirEntry)->Bool:
        if sort_selected == 0:
            return a.stats.st_atimespec.as_nanoseconds() > b.stats.st_atimespec.as_nanoseconds()
        elif sort_selected == 1:
            return a.stats.st_mtimespec.as_nanoseconds() > b.stats.st_mtimespec.as_nanoseconds()
        elif sort_selected == 2:
            return a.stats.st_birthtimespec.as_nanoseconds() > b.stats.st_birthtimespec.as_nanoseconds()
        elif sort_selected == 3:
            return a.stats.st_size > b.stats.st_size
        return False
    @parameter
    fn do_sort():
        for ref d in start_dir:
            var res = d.refresh()
            if res == False:
                try:
                    start_dir = List(DirView(cwd()))
                except e:
                    ...
                break
        for ref d in start_dir:
            sort[f_sort, stable=True](Span(d.content))
    do_sort()

    var error = String("")
    var not_error = String("")
    var colors = List(Fg.blue,Fg.cyan, Fg.green, Fg.magenta, Fg.red)
    for _ in ui:

        Text(error)|Bg.red in ui
        
        Text("Reload paths content") | Bg.green in ui
        if ui[-1].click():
            do_sort()
        widget_value_selector["ShowSize"](ui, size_selected, size_values)
        var tmp_sort_selected = sort_selected
        widget_value_selector["Sort", Fg.blue](ui, sort_selected, sort_values)
        if tmp_sort_selected != sort_selected: do_sort()
        widget_checkbox(ui, "ShowPerm: ", show_perm)

        Text(not_error)|Bg.green in ui
        var all_measuring = ui.start_measuring()
        var all_border_measuring = all_measuring.start_border()

        try: Text(cwd()) in ui except e: ...
        
        var idx = 1
        var need_refresh = False
        for ref dir in start_dir:
            var col = ui.start_measuring()
            var fg_color = colors[(idx%len(colors))]
            try:
                Text(String(dir.path).split("/")[-1]) | fg_color in ui
            except e:...
            var b = col.start_border()

            var tmp_measure = ui.start_measuring()
            for ref e in dir.content:
                var tmp_e = dir.path/e.path
                var color = Fg.green if tmp_e.is_dir() else Fg.default
                Text(e.name) | color in ui
                if ui[-1].click() and e.is_dir:
                    try:
                        not_error = String(tmp_e)
                        var tmp_elem = DirView(tmp_e)
                        if idx == len(start_dir): ...
                        else:
                            while idx != len(start_dir):
                                _=start_dir.pop()
                        start_dir.append(tmp_elem)
                        need_refresh = True
                        break
                    except e:
                        error = String(e)
            tmp_measure^.stop_measuring().move_cursor_after()
            tmp_measure = ui.start_measuring()
            if size_selected>0:
                for e in dir.content:
                    var divisor = 1
                    if size_selected == 2: divisor = 1024
                    elif size_selected == 3: divisor = 1024*1024
                    if divisor ==1:
                        Text(e.stats.st_size)|fg_color.to_bg() in ui
                    else:
                        Text(
                            (e.stats.st_size.__floordiv__(divisor)),
                            "-",
                            (e.stats.st_size.__ceildiv__(divisor))
                        ) | colors[(idx%len(colors))].to_bg() in ui
            var peek = tmp_measure.peek_dimensions()
            if peek.reduce_add() != 0:
                tmp_measure^.stop_measuring().move_cursor_after()
            else:
                __disable_del tmp_measure^.stop_measuring()
            if show_perm:
                for e in dir.content:
                    Text(" ",oct(e.stats.st_mode)[-3:]) in ui
            b^.end_border(ui,colors[(idx%len(colors))])
            col^.stop_measuring().move_cursor_after()
            idx+=1
        if need_refresh:
            do_sort()

        all_border_measuring^.end_border[StyleBorderDouble](ui,Fg.magenta)
        all_measuring^.stop_measuring().move_cursor_below()
