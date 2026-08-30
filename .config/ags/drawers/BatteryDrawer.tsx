import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"

const { TOP, RIGHT } = Astal.WindowAnchor

export default function BatteryDrawer(gdkmonitor: any) {
  const info = createPoll("  N/A", 10000,
    `sh -c 'upower -i $(upower -e | grep BAT 2>/dev/null) 2>/dev/null | awk -F":\\\\t*" "/percentage/{p=\\$2} /state/{s=\\$2} /time to (empty|full)/{t=\\$2} END{printf \"  %s  |  %s  |    %s\", p?p:\"?\", s?s:\"?\", t?t:\"N/A\"}"'`)

  return (
    <window
      name="battery-drawer"
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
        <label class="drawer-title" label="󰁹  Battery" />
        <box class="drawer-item"><label label={info} /></box>
      </box>
    </window>
  )
}
