import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import Gio from "gi://Gio"

const { CENTER } = Astal.WindowAnchor

const MAX_BAR_WIDTH = 200
const LERP_STEP_MS = 16
const LERP_FACTOR = 0.2
const SHOW_MS = 1200

let fadeTimer: number | null = null
let autoHideTimer: number | null = null
let lastWidth = 0

let iconRef: Gtk.Label | null = null
let barRef: Gtk.Box | null = null
let percentRef: Gtk.Label | null = null
let winRef: Gtk.Window | null = null

function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t
}

function showOsd(type: string, value: number) {
  if (!barRef || !iconRef || !percentRef || !winRef) return

  const clamped = Math.min(100, Math.max(0, value))
  const volIcons = ["󰕿", "󰖀", "󰕾"]
  const brightIcons = ["󰃞", "󰃟", "󰃠"]
  const set = type === "volume" ? volIcons : brightIcons
  const iconIdx = Math.min(set.length - 1, Math.floor(clamped / 34))
  const icon = (type === "volume" && clamped === 0) ? "󰝟" : set[iconIdx]

  iconRef.label = icon
  percentRef.label = `${clamped}%`

  const targetWidth = Math.round((clamped / 100) * MAX_BAR_WIDTH)

  if (fadeTimer !== null) { GLib.source_remove(fadeTimer); fadeTimer = null }
  if (autoHideTimer !== null) { GLib.source_remove(autoHideTimer); autoHideTimer = null }

  let current = lastWidth
  GLib.timeout_add(GLib.PRIORITY_DEFAULT, LERP_STEP_MS, function tick() {
    const diff = Math.abs(targetWidth - current)
    if (diff < 1) {
      current = targetWidth
      if (barRef) barRef.width_request = current
      lastWidth = current
      return false
    }
    current = Math.round(lerp(current, targetWidth, LERP_FACTOR))
    if (barRef) barRef.width_request = current
    lastWidth = current
    return true
  })

  winRef.visible = true

  autoHideTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, SHOW_MS, () => {
    autoHideTimer = null
    if (winRef) winRef.visible = false
    if (barRef) barRef.width_request = 0
    lastWidth = 0
    return false
  })
}

export default function OsdDrawer(gdkmonitor: any) {
  const win = (
    <window
      name="osd"
      class="OSD"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.NORMAL}
      keymode={Astal.Keymode.NONE}
      anchor={CENTER}
      margin-bottom={120}
      visible={false}
      application={app}
    >
      <box cssName="osd-box">
        <label cssName="osd-icon" label="" $={(self) => { iconRef = self }} />
        <box cssName="osd-bar-outer" widthRequest={MAX_BAR_WIDTH}>
          <box cssName="osd-bar-inner" widthRequest={0} $={(self) => { barRef = self }} />
        </box>
        <label cssName="osd-percent" label="" $={(self) => { percentRef = self }} />
      </box>
    </window>
  )

  return win
}

// Start socket server for OSD commands
const SOCKET_PATH = "/tmp/ags-osd.sock"
try { GLib.unlink(SOCKET_PATH) } catch {}

const socket = Gio.Socket.new(Gio.SocketFamily.UNIX, Gio.SocketType.DATAGRAM, 0)
socket.bind(Gio.UnixSocketAddress.new(SOCKET_PATH), true)

const source = socket.create_source(GLib.IOCondition.IN, null)
source.set_callback((_s: any, _fd: any, _condition: any) => {
  try {
    const [, addr, , data] = socket.receive_from(1024, null)
    const text = new TextDecoder().decode(data).trim()
    const parts = text.split(" ")
    if (parts.length >= 2) {
      const type = parts[0]
      const value = parseInt(parts[1])
      if (!isNaN(value)) showOsd(type, value)
    }
  } catch {}
  return true
})
source.attach(GLib.MainContext.default())

// Also keep file-based polling as fallback
let lastContent = ""
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 80, () => {
  try {
    const [ok, content] = GLib.file_get_contents("/tmp/ags-osd")
    if (!ok || !content) return true
    const text = new TextDecoder().decode(content).trim()
    if (!text || text === lastContent) return true
    lastContent = text
    const parts = text.split(" ")
    if (parts.length >= 2) {
      const type = parts[0]
      const value = parseInt(parts[1])
      if (!isNaN(value)) showOsd(type, value)
    }
  } catch {}
  return true
})
