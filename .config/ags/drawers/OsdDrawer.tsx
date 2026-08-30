import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import Gio from "gi://Gio"

const { CENTER } = Astal.WindowAnchor

const MAX_BAR_WIDTH = 200
const LERP_STEP_MS = 16
const LERP_FACTOR = 0.18
const FADE_STEP_MS = 20
const FADE_FACTOR = 0.1
const SHOW_MS = 1200

let fadeTimer: number | null = null
let autoHideTimer: number | null = null

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

function fadeInOut(win: Gtk.Window) {
  if (fadeTimer !== null) { GLib.source_remove(fadeTimer); fadeTimer = null }
  if (autoHideTimer !== null) { GLib.source_remove(autoHideTimer); autoHideTimer = null }

  win.opacity = 1
  win.visible = true

  autoHideTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, SHOW_MS, () => {
    autoHideTimer = null
    let opacity = 1.0
    fadeTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, FADE_STEP_MS, () => {
      opacity = lerp(opacity, 0, FADE_FACTOR)
      if (opacity < 0.02) {
        win.opacity = 0
        win.visible = false
        fadeTimer = null
        return false
      }
      win.opacity = opacity
      return true
    })
    return false
  })
}

export default function OsdDrawer(gdkmonitor: any) {
  let barRef: Gtk.Box | null = null
  let iconRef: Gtk.Label | null = null
  let percentRef: Gtk.Label | null = null
  let winRef: Gtk.Window | null = null
  let lastWidth = 0

  const icons = ["󰕿", "󰖀", "󰕾"]
  const brightIcons = ["󰃞", "󰃟", "󰃠"]

  function handleInput(type: string, value: number) {
    if (!barRef || !iconRef || !percentRef || !winRef) return

    const clamped = Math.min(100, Math.max(0, value))
    const set = type === "volume" ? icons : brightIcons
    const muted = type === "volume" && clamped === 0
    const iconIdx = Math.min(set.length - 1, Math.floor(clamped / 34))
    const icon = muted ? "󰝟" : set[iconIdx]

    iconRef.label = icon
    percentRef.label = `${clamped}%`

    const targetWidth = Math.round((clamped / 100) * MAX_BAR_WIDTH)
    animateBar(barRef, lastWidth, targetWidth)
    lastWidth = targetWidth

    fadeInOut(winRef)
  }

  const iconLabel = <label cssName="osd-icon" label="" ref={(el) => { iconRef = el }} />
  const barOuter = <box cssName="osd-bar-outer" widthRequest={MAX_BAR_WIDTH}>
    <box cssName="osd-bar-inner" ref={(el) => { barRef = el }} widthRequest={0} />
  </box>
  const percentLabel = <label cssName="osd-percent" label="" ref={(el) => { percentRef = el }} />

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
      ref={(el) => { winRef = el }}
    >
      <box cssName="osd-box">
        {iconLabel}
        {barOuter}
        {percentLabel}
      </box>
    </window>
  )

  // Watch file for commands
  const file = Gio.File.new_for_path("/tmp/ags-osd")
  try { file.delete(null) } catch {}
  const monitor = file.monitor_file(Gio.FileMonitorFlags.NONE, null)
  monitor.connect("changed", () => {
    try {
      const [ok, content] = GLib.file_get_contents("/tmp/ags-osd")
      if (!ok || !content) return
      const text = new TextDecoder().decode(content).trim()
      const parts = text.split(" ")
      if (parts.length < 2) return
      const type = parts[0]
      const value = parseInt(parts[1])
      if (isNaN(value)) return
      handleInput(type, value)
    } catch {}
  })

  return win
}
