import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

const { CENTER } = Astal.WindowAnchor

const MAX_BAR_WIDTH = 200
const LERP_STEP_MS = 16
const LERP_FACTOR = 0.2
const SHOW_MS = 1200

let fadeTimer: number | null = null
let autoHideTimer: number | null = null
let lastValue = -1
let lastType = ""
let lastWidth = 0

function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t
}

function animateBar(bar: Gtk.Box, from: number, to: number) {
  let current = from
  const id = GLib.timeout_add(GLib.PRIORITY_DEFAULT, LERP_STEP_MS, () => {
    const diff = Math.abs(to - current)
    if (diff < 1) {
      current = to
      bar.width_request = current
      return false
    }
    current = Math.round(lerp(current, to, LERP_FACTOR))
    bar.width_request = current
    return true
  })
  return id
}

export default function OsdDrawer(gdkmonitor: any) {
  let iconRef: Gtk.Label | null = null
  let barRef: Gtk.Box | null = null
  let percentRef: Gtk.Label | null = null

  const volIcons = ["󰕿", "󰖀", "󰕾"]
  const brightIcons = ["󰃞", "󰃟", "󰃠"]

  const iconLabel = (
    <label cssName="osd-icon" label="" $={(self) => { iconRef = self }} />
  )

  const barInner = (
    <box cssName="osd-bar-inner" widthRequest={0} $={(self) => { barRef = self }} />
  )

  const barOuter = (
    <box cssName="osd-bar-outer" widthRequest={MAX_BAR_WIDTH}>
      {barInner}
    </box>
  )

  const percentLabel = (
    <label cssName="osd-percent" label="" $={(self) => { percentRef = self }} />
  )

  const contentBox = (
    <box cssName="osd-box">
      {iconLabel}
      {barOuter}
      {percentLabel}
    </box>
  )

  let winRef: Gtk.Window | null = null

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
      $={(self) => { winRef = self }}
    >
      {contentBox}
    </window>
  )

  // Poll the trigger file every 100ms
  const poll = createPoll("", 100, () => {
    try {
      const [ok, content] = GLib.file_get_contents("/tmp/ags-osd")
      if (!ok || !content) return ""
      const text = new TextDecoder().decode(content).trim()
      return text
    } catch {
      return ""
    }
  })

  poll.connect("notify::g-type", () => {})

  GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => {
    try {
      const [ok, content] = GLib.file_get_contents("/tmp/ags-osd")
      if (!ok || !content) return true
      const text = new TextDecoder().decode(content).trim()
      if (!text) return true

      const parts = text.split(" ")
      if (parts.length < 2) return true
      const type = parts[0]
      const value = parseInt(parts[1])
      if (isNaN(value)) return true

      // Only trigger if value changed
      if (type === lastType && value === lastValue) return true
      lastType = type
      lastValue = value

      const clamped = Math.min(100, Math.max(0, value))
      const set = type === "volume" ? volIcons : brightIcons
      const iconIdx = Math.min(set.length - 1, Math.floor(clamped / 34))
      const icon = (type === "volume" && clamped === 0) ? "󰝟" : set[iconIdx]

      if (iconRef) iconRef.label = icon
      if (percentRef) percentRef.label = `${clamped}%`

      const targetWidth = Math.round((clamped / 100) * MAX_BAR_WIDTH)
      if (barRef) animateBar(barRef, lastWidth, targetWidth)
      lastWidth = targetWidth

      if (winRef) {
        winRef.visible = true

        if (fadeTimer !== null) { GLib.source_remove(fadeTimer); fadeTimer = null }
        if (autoHideTimer !== null) { GLib.source_remove(autoHideTimer); autoHideTimer = null }

        autoHideTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, SHOW_MS, () => {
          autoHideTimer = null
          winRef!.visible = false
          if (barRef) barRef.width_request = 0
          lastWidth = 0
          return false
        })
      }
    } catch {}
    return true
  })

  return win
}
