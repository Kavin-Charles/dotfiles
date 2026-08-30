import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

const { CENTER } = Astal.WindowAnchor

const MAX_BAR_WIDTH = 200
const LERP_STEP_MS = 16
const LERP_FACTOR = 0.2
const SHOW_MS = 1200
const POLL_MS = 80

let iconRef: Gtk.Label | null = null
let barRef: Gtk.Box | null = null
let percentRef: Gtk.Label | null = null
let winRef: Gtk.Window | null = null
let lastWidth = 0
let lastContent = ""
let fadeSourceId = 0
let hideSourceId = 0
let pollSourceId = 0
let lerpSourceId = 0

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

  if (fadeSourceId) { GLib.source_remove(fadeSourceId); fadeSourceId = 0 }
  if (hideSourceId) { GLib.source_remove(hideSourceId); hideSourceId = 0 }
  if (lerpSourceId) { GLib.source_remove(lerpSourceId); lerpSourceId = 0 }

  let current = lastWidth
  lerpSourceId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, LERP_STEP_MS, () => {
    const diff = Math.abs(targetWidth - current)
    if (diff < 1) {
      current = targetWidth
      if (barRef) barRef.width_request = current
      lastWidth = current
      lerpSourceId = 0
      return false
    }
    current = Math.round(lerp(current, targetWidth, LERP_FACTOR))
    if (barRef) barRef.width_request = current
    lastWidth = current
    return true
  })

  winRef.visible = true

  hideSourceId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, SHOW_MS, () => {
    hideSourceId = 0
    if (winRef) winRef.visible = false
    if (barRef) barRef.width_request = 0
    lastWidth = 0
    return false
  })
}

function pollFile() {
  try {
    const [ok, content] = GLib.file_get_contents("/tmp/ags-osd")
    if (!ok || !content) return
    const text = new TextDecoder().decode(content).trim()
    if (!text || text === lastContent) return
    lastContent = text
    const parts = text.split(" ")
    if (parts.length >= 2) {
      const type = parts[0]
      const value = parseInt(parts[1])
      if (!isNaN(value)) showOsd(type, value)
    }
  } catch {}
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
      $={() => {
        if (pollSourceId) GLib.source_remove(pollSourceId)
        pollSourceId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, POLL_MS, () => {
          pollFile()
          return true
        })
      }}
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
