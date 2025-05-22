from `ui-terminal-mojo` import *
from collections import Dict

@value
struct Project:
    var name: String
    var is_edited_name: Bool
    var bpm: Int
    var sounds: Dict[String, Int]
    var sequences: List[Sequence]
@value
struct Sequence:
    var audio_name: String
    var start: Int
    var stop: Int
    var is_edited_audio_name: Bool

fn main():

    var ui = UI()
    var project = Project(
        "MyProject",
        False,
        32768,
        Dict[String, Int](),
        List[Sequence]()
    )
    var show_loadable_audios = False
    var example_audios_to_load = List[Tuple[String, Int]](
        (String("drums.wav"), 500), (String("snare.wav"), 300), (String("melody.wav"), 400)
    )
    for _ in ui:
        Text("My small app") | Bg.yellow in ui

        # input widget for project name:
        input_buffer["Project name:"](ui, project.name, project.is_edited_name)
        " " in ui

        # show how much sequences and audios in project
        "Sequences" in ui
        tag(ui, Bg.blue, len(project.sequences))
        "Audios" in ui
        tag(ui, Bg.yellow, len(project.sounds))
        " " in ui

        # collapsible menu to append to audios
        "Menu audios to load" in ui
        # make this ^ blue:
        ui[-1] |= Bg.blue
        # turn it into a button:
        if ui[-1].click():
            show_loadable_audios^=True

        if show_loadable_audios:
            for e in example_audios_to_load:
                Text(e[][0]) in ui
                tooltip[Bg.blue](ui, String("^size:", e[][1]) )
                if ui[-2].click():
                    # if already loaded, no append:
                    if e[][0] not in project.sounds:
                        project.sounds[e[][0]] = e[][1]

        " " in ui

        # widget for adding new empty sequences
        "Add sequence" in ui
        if ui[-1].click():
            project.sequences.append(
                Sequence("a.wav",0,0, False)
            )

        # widget to show and change sequences
        for s in project.sequences:
            input_buffer["Audio:"](ui, s[].audio_name, s[].is_edited_audio_name)

            #make previous widget 16 cells fixed:
            ljust[16](ui)

            # stop if is not in project
            if not s[].audio_name in project.sounds:
                # show this error message
                "Not in audios !" in ui
                ui[-1] |= Bg.magenta
                continue

            #new line
            " " in ui

            var group_measurement = ui.start_measuring()
            var tmp_measurement = ui.start_measuring()
            # show start
            Text(s[].start) in ui
            ljust[8](ui)
            if ui[-1].click(): s[].start+=1
            tooltip[Bg.green](ui, String(s[].start))
            tmp_measurement^.stop_measuring().move_cursor_after()

            # show stop
            Text(s[].stop) in ui
            if ui[-1].click(): s[].stop+=1
            tooltip[Bg.red](ui, String(s[].stop))
            ljust[8](ui)
            group_measurement^.stop_measuring().move_cursor_below()

            " " in ui
