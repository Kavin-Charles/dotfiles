import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"

const { TOP, RIGHT } = Astal.WindowAnchor

export default function CalendarDrawer(gdkmonitor: any) {
  const time = createPoll("", 1000, "date '+  %H:%M:%S'")
  const date = createPoll("", 60000, "date '+  %A, %d %B %Y'")

  return (
    <window
      name="calendar-drawer"
      class="Drawer"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.NORMAL}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={TOP | RIGHT}
      margin-top={30}
      visible={false}
      application={app}
      setup={(self) => {
        self.connect("notify::is-active", () => {
          if (!self.isActive && self.visible) {
            if (GLib.file_test("/tmp/ags-drawer-lock", GLib.FileTest.EXISTS)) return
            self.visible = false
            GLib.file_set_contents("/tmp/ags-drawer-open", "")
          }
        })
      }}
    >
      <box orientation={Gtk.Orientation.VERTICAL}>
        <label class="drawer-title" label="󰥔  Clock" />
        <box class="drawer-item" orientation={Gtk.Orientation.VERTICAL}>
          <label label={time} />
          <label label={date} />
        </box>
        <box class="drawer-item"><Gtk.Calendar /></box>
      </box>
    </window>
  )
}
