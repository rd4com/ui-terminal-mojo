from json import *
from `ui-terminal-mojo` import *

fn print_json[O:Origin](
        owned started_measurement: StartedMeasurment,
        arg_: Optional[json.JSONValue[O]],
    ):
    var ui_ptr = started_measurement.ui_ptr
    if not arg_: 
        ui_ptr[].move_cursor_below(started_measurement^.stop_measuring())
        return
    var arg = arg_.value()
    if arg._is_number():
        String("number(", arg, ")", sep="") in ui_ptr[]
    if arg._is_string():
        try:
            String("str(\"",arg._as_string(), "\")", sep="") in ui_ptr[]
        except e: ...
    if arg._is_array():
        var b = started_measurement.start_border()
        Text("list") | Bg.cyan in ui_ptr[]
        try:
            var tmp = arg._as_array()
            if ui_ptr[][-1].hover():
                Text(String(len(tmp._storage), " elements"))|Bg.magenta in ui_ptr[]
            var idx = 0
            for v in tmp._storage:
                var entry_measurement = ui_ptr[].start_measuring()
                var tmp_measurement = ui_ptr[].start_measuring()
                Text(idx) | Fg.cyan in ui_ptr[]
                ljust[4](ui_ptr[])
                ui_ptr[].move_cursor_after(tmp_measurement^.stop_measuring())
                tmp_measurement = ui_ptr[].start_measuring()
                print_json(tmp_measurement^,v[])
                ui_ptr[].move_cursor_below(entry_measurement^.stop_measuring())
                idx+=1
        except e: ...
        b^.end_border[StyleBorderCurved](ui_ptr[], Fg.cyan)
    if arg._is_object():
        var b = started_measurement.start_border()
        Text("dict") | Bg.green in ui_ptr[]
        try:
            var tmp = arg._as_object()
            if ui_ptr[][-1].hover():
                Text(String(len(tmp), " key value pairs"))|Bg.magenta in ui_ptr[]
            for k in tmp:
                var entry_measurement = ui_ptr[].start_measuring()
                var tmp_measurement = ui_ptr[].start_measuring()
                var tmp_k = k[]
                Text("\"" + tmp_k + "\" ") | Fg.green in ui_ptr[]
                ui_ptr[].move_cursor_after(tmp_measurement^.stop_measuring())
                tmp_measurement = ui_ptr[].start_measuring()
                var value = tmp.find(tmp_k)
                print_json(tmp_measurement^, value)
                ui_ptr[].move_cursor_below(entry_measurement^.stop_measuring())
        except e: ...
        b^.end_border(ui_ptr[], Fg.green)
    ui_ptr[].move_cursor_below(started_measurement^.stop_measuring())


def main():
    var input = String("{\"k_one\":[1,\"two\", {\"one\": [1, 2]}], \"a\":1}")
    var as_json = loads(input)

    var ui = UI()
    for _ in ui:
        var all_screen = ui.start_measuring()
        var b = all_screen.start_border()
        Text(input) | Bg.blue in ui
        var started_measurement = ui.start_measuring()
        print_json(started_measurement^, as_json)
        b^.end_border[StyleBorderDouble](ui, Fg.magenta)
        ui.move_cursor_below(all_screen^.stop_measuring())
