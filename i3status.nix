{
  environment.etc."i3status.conf".text = ''
    general {
        colors = true
        output_format = "i3bar"
        interval = 2
        color_good = "#a6e3a1"
        color_degraded = "#f9e2af"
        color_bad = "#f38ba8"
    }

    order += "wireless _first_"
    order += "ethernet _first_"
    order += "cpu_usage"
    order += "memory"
    order += "disk /"
    order += "battery all"
    order += "tztime local"

    wireless _first_ {
        format_up = "WiFi: %essid (%quality)"
        format_down = ""
    }

    ethernet _first_ {
        format_up = "ETH: %ip"
        format_down = ""
    }

    cpu_usage {
        format = "CPU: %usage"
        degraded_threshold = 75
        max_threshold = 90
    }

    memory {
        format = "RAM: %used / %total"
        threshold_degraded = "20%"
        threshold_critical = "10%"
    }

    disk "/" {
        format = "Disk: %avail"
        low_threshold = 10
        threshold_type = percentage_avail
    }

    battery all {
        format = "%status %percentage %remaining"
        format_down = "No battery"
        status_chr = "Charging"
        status_bat = "BAT:"
        status_unk = "Unknown"
        status_full = "Full"
        low_threshold = 20
        threshold_type = percentage
        last_full_capacity = true
        integer_battery_capacity = true
    }

    tztime local {
        format = "%a %b %d | %I:%M %p"
    }
  '';
}
