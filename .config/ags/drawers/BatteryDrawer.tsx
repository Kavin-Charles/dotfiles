import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { createBinding, createComputed } from "ags"
import Battery from "gi://AstalBattery"
import GLib from "gi://GLib"

const { TOP, RIGHT } = Astal.WindowAnchor

export default function BatteryDrawer(gdkmonitor: any) {
  const battery = Battery.Device.get_default()
  const percentage = createBinding(battery, "percentage")
  const state = createBinding(battery, "state")
  const empty = createBinding(battery, "timeToEmpty")
  const full = createBinding(battery, "timeToFull")
  const info = createComputed(() => {
    const status = state()
    const names = ["Unknown", "Charging", "Discharging", "Empty", "Fully charged", "Waiting to charge", "Waiting to discharge"]
    const seconds = status === Battery.State.CHARGING ? full() : empty()
    const minutes = Math.ceil(seconds / 60)
    const remaining = seconds > 0 ? `${Math.floor(minutes / 60)}h ${minutes % 60}m` : "N/A"
    return `${Math.round(percentage() * 100)}%  |  ${names[status] ?? "Unknown"}  |  ${remaining}`
  })

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
