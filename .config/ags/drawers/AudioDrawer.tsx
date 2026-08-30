import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import GLib from "gi://GLib"

const { TOP, RIGHT } = Astal.WindowAnchor

export default function AudioDrawer(gdkmonitor: any) {
  return (
    <window
      name="audio-drawer"
      class="Drawer"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.NORMAL}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={TOP | RIGHT}
      margin-top={30}
      visible={false}
      application={app}
      $={(self) => {
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
        <label class="drawer-title" label="󰕾  Audio" />
        <button class="drawer-item primary" onClicked={() => execAsync("pavucontrol")}>
          <box><label class="drawer-icon" label="󰐌" /><label label="Open Audio Settings" /></box>
        </button>
      </box>
    </window>
  )
}
