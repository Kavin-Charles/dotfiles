import app from "ags/gtk4/app"
import style from "./style.scss"
import { execAsync } from "ags/process"
import NetworkDrawer from "./drawers/NetworkDrawer"
import BluetoothDrawer from "./drawers/BluetoothDrawer"
import AudioDrawer from "./drawers/AudioDrawer"
import BatteryDrawer from "./drawers/BatteryDrawer"
import CalendarDrawer from "./drawers/CalendarDrawer"

app.start({
  css: style,
  main() {
    execAsync("rm -f /tmp/ags-drawer-open")
    app.get_monitors().map((m) => {
      NetworkDrawer(m)
      BluetoothDrawer(m)
      AudioDrawer(m)
      BatteryDrawer(m)
      CalendarDrawer(m)
    })
  },
})
