#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, GLib, Gdk
import signal, sys

icon_label = None
bar_inner = None
percent_label = None
window = None
app = None

last_width = 0
target_width = 0
current_opacity = 1.0
hide_timer_id = None
lerp_timer_id = None
fade_timer_id = None

MAX_BAR = 200
LERP_FACTOR = 0.18
FADE_FACTOR = 0.12

def lerp(a, b, t):
    return a + (b - a) * t

def on_lerp_tick():
    global last_width, lerp_timer_id
    diff = abs(target_width - last_width)
    if diff < 1:
        last_width = target_width
        bar_inner.set_size_request(target_width, -1)
        lerp_timer_id = None
        return False
    last_width = int(lerp(last_width, target_width, LERP_FACTOR))
    bar_inner.set_size_request(last_width, -1)
    return True

def on_fade_tick():
    global current_opacity, fade_timer_id
    current_opacity = lerp(current_opacity, 0, FADE_FACTOR)
    if current_opacity < 0.02:
        window.set_opacity(0)
        window.set_visible(False)
        bar_inner.set_size_request(0, -1)
        last_width = 0
        current_opacity = 1.0
        fade_timer_id = None
        return False
    window.set_opacity(current_opacity)
    return True

def auto_hide():
    global hide_timer_id, fade_timer_id
    hide_timer_id = None
    if fade_timer_id:
        GLib.source_remove(fade_timer_id)
    fade_timer_id = GLib.timeout_add(20, on_fade_tick)
    return False

def show_osd(type_, value):
    global target_width, last_width, hide_timer_id, lerp_timer_id, fade_timer_id, current_opacity

    value = max(0, min(100, value))

    if type_ == "volume":
        icons = ["󰕿", "󰖀", "󰕾"]
        icon = "󰝟" if value == 0 else icons[min(2, value // 34)]
    else:
        icons = ["󰃞", "󰃟", "󰃠"]
        icon = icons[min(2, value // 34)]

    icon_label.set_text(icon)
    percent_label.set_text(f"{value}%")

    target_width = int((value / 100) * MAX_BAR)

    for tid in [hide_timer_id, lerp_timer_id, fade_timer_id]:
        if tid:
            GLib.source_remove(tid)
    hide_timer_id = None
    lerp_timer_id = None
    fade_timer_id = None

    current_opacity = 1.0
    window.set_opacity(1.0)
    window.set_visible(True)

    lerp_timer_id = GLib.timeout_add(16, on_lerp_tick)
    hide_timer_id = GLib.timeout_add(1200, auto_hide)

    return True

def poll_file():
    try:
        with open('/tmp/ags-osd', 'r') as f:
            content = f.read().strip()
        if not content:
            return True
        parts = content.split()
        if len(parts) >= 2:
            type_ = parts[0]
            value = int(parts[1])
            show_osd(type_, value)
    except:
        pass
    return True


def build_ui(a):
    global window, icon_label, bar_inner, percent_label

    css = Gtk.CssProvider()
    css.load_from_data(b"""
        window { background: transparent; }
        .osd-box {
            background: #1c1c1c;
            border: 1px solid #45475a;
            border-radius: 12px;
            padding: 10px 16px;
            min-width: 300px;
        }
        .osd-icon {
            font-size: 22px;
            color: #89b4fa;
            font-family: "Ubuntu Nerd Font";
            min-width: 30px;
        }
        .osd-bar-outer {
            min-width: 200px;
            min-height: 8px;
            background: #313244;
            border-radius: 4px;
            margin: 6px 0;
        }
        .osd-bar-inner {
            min-height: 8px;
            min-width: 0px;
            background: #89b4fa;
            border-radius: 4px;
        }
        .osd-percent {
            font-size: 14px;
            font-weight: bold;
            color: #cdd6f4;
            font-family: "Ubuntu Nerd Font";
            min-width: 40px;
        }
    """)
    Gtk.StyleContext.add_provider_for_display(
        Gdk.Display.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    window = Gtk.ApplicationWindow(application=a)
    window.set_decorated(False)
    window.set_resizable(False)
    window.set_opacity(0)
    window.set_visible(False)

    box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
    box.get_style_context().add_class('osd-box')

    icon_label = Gtk.Label()
    icon_label.get_style_context().add_class('osd-icon')
    box.append(icon_label)

    bar_outer = Gtk.Box()
    bar_outer.get_style_context().add_class('osd-bar-outer')
    bar_inner = Gtk.Box()
    bar_inner.get_style_context().add_class('osd-bar-inner')
    bar_outer.append(bar_inner)
    box.append(bar_outer)

    percent_label = Gtk.Label()
    percent_label.get_style_context().add_class('osd-percent')
    box.append(percent_label)

    window.set_child(box)
    window.set_size_request(320, 50)

    display = Gdk.Display.get_default()
    monitor = display.get_monitors().get_item(0)
    geom = monitor.get_geometry()
    x = geom.x + (geom.width - 320) // 2
    y = geom.y + geom.height - 160
    window.move(x, y)

    window.present()

    GLib.timeout_add(80, poll_file)


app = Adw.Application(application_id='com.osd.indicator')
app.connect('activate', build_ui)
app.run(None)
