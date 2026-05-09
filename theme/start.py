import os
import socket
import time
import subprocess
import json
import re
import sys
from datetime import datetime
import pyfiglet

# ═══════════════════════════════
# ZYROXTERM v1.1 
# Author: Farel Alfareza
# © 2026 ThePort Studio
# ═══════════════════════════════

system_version = 1.1

# ── Color Palette ──
C_BLACK = "[38;5;232m"
C_DGRAY = "[38;5;235m"
C_GRAY = "[38;5;240m"
C_MGRAY = "[38;5;245m"
C_LGRAY = "[38;5;250m"
C_WHITE = "[38;5;255m"


C_TEAL = "[38;5;39m"
C_CYAN = "[38;5;81m"
C_SKY = "[38;5;75m"
C_BLUE = "[38;5;69m"
C_VIOLET = "[38;5;63m"
C_PURPLE = "[38;5;27m"
C_MAGENTA = "[38;5;33m"
C_PINK = "[38;5;45m"
C_ROSE = "[38;5;117m"
C_RED = "[38;5;196m"
C_ORANGE = "[38;5;75m"
C_GOLD = "[38;5;117m"
C_YELLOW = "[38;5;159m"
C_LIME = "[38;5;81m"
C_GREEN = "[38;5;75m"

# Background colors for PS1 text styling
BG_PURPLE = "[48;5;27m"
BG_PINK = "[48;5;39m"
BG_CYAN = "[48;5;75m"
BG_TEAL = "[48;5;33m"
BG_DARK = "[48;5;235m"
BG_BLACK = "[48;5;232m"
BG_ROSE = "[48;5;117m"
BG_GOLD = "[48;5;159m"
BG_GREEN = "[48;5;81m"


RST   = "\033[0m"
BOLD  = "\033[1m"
DIM   = "\033[2m"
ITALIC= "\033[3m"

# ── State ──
command_count = 0
max_commands = 10
command_percentage = 0

def update_command_usage():
    global command_count, command_percentage
    command_count += 1
    command_percentage = (command_count / max_commands) * 100
    if command_count >= max_commands:
        command_count = 0
        command_percentage = 0
    return command_percentage

def reset_command_usage():
    global command_count, command_percentage
    command_count = 0
    command_percentage = 0
    return command_percentage

def tw():
    try:
        return os.get_terminal_size().columns
    except:
        return 80

def clear():
    os.system("clear")

def strip_ansi(s):
    """Remove ANSI escape codes for length calculation"""
    ansi_pattern = re.compile(r'\x1B(?:[@-Z\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_pattern.sub('', s)

def center_text(text, color=C_WHITE):
    w = tw()
    clean = strip_ansi(text)
    pad = max(0, (w - len(clean)) // 2)
    return f"{' ' * pad}{color}{text}{RST}"

def shorten_path(path):
    home = os.environ.get("HOME", "/data/data/com.termux/files/home")
    if path == home:
        return "~"
    if path.startswith(home):
        rel = path[len(home):].lstrip('/')
        parts = rel.split('/')
        if len(parts) == 1:
            return f"~/{parts[0]}"
        elif len(parts) == 2:
            return f"~/{parts[0]}/{parts[1]}"
        else:
            return f"~/.../{parts[-1]}"
    else:
        parts = path.split('/')
        if len(parts) <= 2:
            return path
        else:
            return f".../{parts[-1]}"

def get_gradient_color(pct):
    if pct < 25:
        return C_GREEN
    elif pct < 50:
        return C_TEAL
    elif pct < 75:
        return C_SKY
    elif pct < 90:
        return C_GOLD
    else:
        return C_ROSE

# ═══════════════════════════════════════════════════════════
# SYSTEM INFO GATHERERS
# ═══════════════════════════════════════════════════════════

def get_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"

def get_bat():
    try:
        r = subprocess.run(["termux-battery-status"], capture_output=True, text=True, timeout=2)
        if r.stdout:
            d = json.loads(r.stdout)
            return d.get("percentage", 0), d.get("status", "UNKNOWN")
    except:
        pass
    return None, None

def get_wifi():
    try:
        r = subprocess.run(["termux-wifi-connectioninfo"], capture_output=True, text=True, timeout=2)
        if r.stdout:
            d = json.loads(r.stdout)
            return d.get("ssid", "Unknown")
    except:
        pass
    return "No Connection"

def get_disk_usage():
    try:
        st = os.statvfs("/data/data/com.termux/files/home")
        total = st.f_blocks * st.f_frsize
        free = st.f_bfree * st.f_frsize
        used = total - free
        return (used / total) * 100
    except:
        return 0

def get_cpu():
    try:
        with open("/proc/loadavg", "r") as f:
            return f.read().split()[0]
    except:
        return "0.00"

def get_mem():
    try:
        with open("/proc/meminfo", "r") as f:
            lines = f.readlines()
            total = int(lines[0].split()[1])
            available = int(lines[2].split()[1]) if len(lines) > 2 else total
            used = total - available
            return (used / total) * 100
    except:
        return 0

def get_os_info():
    try:
        with open("/data/data/com.termux/files/usr/etc/os-release", "r") as f:
            for line in f:
                if "PRETTY_NAME" in line:
                    return line.split("=")[1].strip().strip('"')
    except:
        pass
    return "Termux"

def get_shell():
    return os.environ.get("SHELL", "/bin/bash").split("/")[-1]

def get_device_name():
    try:
        return socket.gethostname()
    except:
        return "termux"

def get_uptime():
    try:
        with open("/proc/uptime", "r") as f:
            uptime_seconds = float(f.read().split()[0])
            hours = int(uptime_seconds // 3600)
            minutes = int((uptime_seconds % 3600) // 60)
            return f"{hours}h {minutes}m"
    except:
        return "Unknown"

def get_available_commands():
    commands = set()
    path_dirs = os.environ.get("PATH", "").split(":")
    for path_dir in path_dirs:
        if os.path.exists(path_dir):
            try:
                for item in os.listdir(path_dir):
                    cmd_path = os.path.join(path_dir, item)
                    if os.path.isfile(cmd_path) and os.access(cmd_path, os.X_OK):
                        commands.add(item)
            except:
                pass
    builtins = ["cd", "exit", "clear", "help", "pwd", "echo", "export", "unset", "alias", "unalias"]
    commands.update(builtins)
    return sorted(list(commands))

# ═══════════════════════════════════════════════════════════
# VISUAL COMPONENTS
# ═══════════════════════════════════════════════════════════

def draw_bar(pct, width=20):
    filled = int(width * pct / 100)
    empty = width - filled
    color = get_gradient_color(pct)
    return f"{color}{'━' * filled}{C_DGRAY}{'╺' * empty}{RST}"

def draw_mini_bar(pct, width=6):
    filled = int(width * pct / 100)
    empty = width - filled
    color = get_gradient_color(pct)
    return f"{color}{'▰' * filled}{C_DGRAY}{'▱' * empty}{RST}"

def draw_separator(char="═", color=C_DGRAY):
    print(f"{color}{char * tw()}{RST}")

# ═══════════════════════════════════════════════════════════
# BANNER & NEOFETCH
# ═══════════════════════════════════════════════════════════

def draw_banner():
    clear()
    w = tw()

    logo = pyfiglet.figlet_format("ZyroXterm", width=w)
    lines = [ln for ln in logo.split("\n") if ln.strip()]

    gradient = [C_PURPLE, C_MAGENTA, C_PINK, C_ROSE, C_GOLD, C_TEAL, C_CYAN]

    print()
    for i, ln in enumerate(lines):
        color = gradient[i % len(gradient)]
        print(f"{BOLD}{color}{ln.center(w)}{RST}")

    subtitle = f"{C_DGRAY}◆ {C_SKY}by fareldev-hub {C_DGRAY}│ {C_SKY}ThePort Studio {C_DGRAY}│ {C_SKY}v{system_version} {C_DGRAY}◆{RST}"
    print(f"\n{center_text(subtitle)}")

    print(f"{C_PURPLE}╰{'━' * (w - 2)}╯{RST}")
    print()

def draw_neofetch():
    os_name = get_os_info().split()[0] if get_os_info() else "Termux"
    device = get_device_name()
    shell = get_shell()
    ip = get_ip()
    wifi = get_wifi()[:22]
    mem = get_mem()
    disk = get_disk_usage()

    art = [
        f"{C_PURPLE}    ▓▓▓▓▓▓    {RST}",
        f"{C_MAGENTA}  ▓▓      ▓▓  {RST}",
        f"{C_PINK} ▓▓  {C_WHITE}◆◆{C_PINK}    ▓▓ {RST}",
        f"{C_ROSE}▓▓  {C_WHITE}◆◆◆◆{C_ROSE}    ▓▓{RST}",
        f"{C_GOLD}▓▓  {C_WHITE}◆◆◆◆{C_GOLD}    ▓▓{RST}",
        f"{C_TEAL} ▓▓  {C_WHITE}◆◆{C_TEAL}    ▓▓ {RST}",
        f"{C_CYAN}  ▓▓      ▓▓  {RST}",
        f"{C_SKY}    ▓▓▓▓▓▓    {RST}"
    ]

    info_rows = [
        (f"{C_SKY}OS{RST}",     f"{C_WHITE}{os_name}{RST}"),
        (f"{C_SKY}HOST{RST}",   f"{C_WHITE}{device}{RST}"),
        (f"{C_SKY}SHELL{RST}",  f"{C_WHITE}{shell}{RST}"),
        (f"{C_SKY}WIFI{RST}",   f"{C_WHITE}{wifi}{RST}"),
        (f"{C_SKY}IP{RST}",     f"{C_WHITE}{ip}{RST}"),
        (f"{C_SKY}MEM{RST}",    f"{C_WHITE}{int(mem)}% {draw_bar(mem, 15)}{RST}"),
        (f"{C_SKY}DISK{RST}",   f"{C_WHITE}{int(disk)}% {draw_bar(disk, 15)}{RST}"),
    ]

    print()
    max_label = max(len(strip_ansi(label)) for label, _ in info_rows)

    for i, (art_line, (label, value)) in enumerate(zip(art, info_rows)):
        print(f"{art_line}  {C_DGRAY}│{RST} {label:<{max_label + 2}} {C_DGRAY}→{RST} {value}")

    for j in range(len(info_rows), len(art)):
        print(f"{art[j]}")

    print()
    draw_separator("─", C_DGRAY)

# ═══════════════════════════════════════════════════════════
# DOUBLE LINE PS1 - USER REQUESTED STYLE
# ═══════════════════════════════════════════════════════════

def create_prompt():
  
    global command_percentage
    path = shorten_path(os.getcwd())
    bat, bst = get_bat()
    device = get_device_name()

    # Background blocks untuk baris 1
    user_block   = f"{BG_PURPLE}{C_WHITE} root {RST}"
    at_block     = f"{BG_DARK}{C_MGRAY} @ {RST}"
    host_block   = f"{BG_PINK}{C_WHITE} {device} {RST}"
    colon_block  = f"{BG_DARK}{C_MGRAY} : {RST}"
    path_block   = f"{BG_CYAN}{C_BLACK} {path} {RST}"
    dollar_block = f"{BG_TEAL}{C_WHITE} $ {RST}"

    # Build baris 1
    line1 = user_block + at_block + host_block + colon_block + path_block + dollar_block

    # Command usage indicator
    cmd_bar = draw_mini_bar(command_percentage, 6)
    cmd_pct_color = get_gradient_color(command_percentage)
    cmd_indicator = f" {C_DGRAY}[{cmd_bar} {cmd_pct_color}{int(command_percentage)}%{C_DGRAY}]{RST}"

    # Battery indicator
    bat_indicator = ""
    if bat:
        bat_icon = "⚡" if bst == "CHARGING" else "🔋"
        bat_color = C_GREEN if bat > 50 else C_GOLD if bat > 25 else C_ROSE
        bat_indicator = f" {bat_color}{bat_icon}{bat}%{RST}"

    line1_full = line1 + bat_indicator

    connector = f"{C_PURPLE}╰{C_MAGENTA}──{C_PINK}──{C_ROSE}⫸{RST}"
    prompt_symbol = f"{C_CYAN}${RST}"
    

    waktu_lokal = datetime.now()
    waktu_format = waktu_lokal.strftime("%d %B %Y, %H:%M:%S")
    block = f"{C_PURPLE}╠═𓊈{RST}{BG_DARK}{cmd_indicator}{RST}"
    block1 = f"{C_PURPLE}╭═𓊈{RST}{BG_DARK}{waktu_format}{RST}"
    prompt_symbol = f"{C_CYAN}${RST}"

    line2 = f"{connector} {prompt_symbol}"

    print(f"\n{block1}\n{line1_full}\n{block}\n{line2} ", end="")
    return ""

# ═══════════════════════════════════════════════════════════
# HELP - VERTICAL LISTING
# ═══════════════════════════════════════════════════════════

def print_help():
    w = tw()
    cmds = get_available_commands()

    internal_cmds = [
        ("deb install",   "linux debian install"),
        ("bun install",   "linux ubuntu install"),
        ("arch install",   "linux arch install"),
        ("debian run",   "start linux debian"),
        ("ubuntu run",   "start linux ubuntu"),
        ("arch run",   "start linux arch"),
        ("exit",   "Exit terminal session"),
        ("clear",  "Clear screen & redraw"),
        ("help",   "Show this help menu"),
        ("sys",    "System info with animation"),
        ("about",  "Author & project info"),
        ("restart", "Restart shell"),
        ("uninstall",   "Uninstall ZyroXterm"),
        ("reset",  "Reset command counter"),
    ]

    print()

    # Header
    print(f"{C_PURPLE}╭{'━' * (w - 2)}╮{RST}")
    title = f"{BOLD}{C_WHITE}ZYROXTERM COMMAND REFERENCE{RST}"
    print(f"{C_PURPLE}│{RST} {center_text(title).strip()} {C_PURPLE}│{RST}")
    print(f"{C_PURPLE}┣{'━' * (w - 2)}┫{RST}")

    # Internal Commands
    section_title = f"{BOLD}{C_CYAN}◆ INTERNAL COMMANDS{RST}"
    print(f"{C_PURPLE}│{RST} {section_title}")
    print(f"{C_PURPLE}│{RST}")

    for cmd, desc in internal_cmds:
        line = f"{C_PURPLE}│{RST}   {C_CYAN}▸ {C_WHITE}{cmd:<12}{RST} {C_DGRAY}│{RST} {C_MGRAY}{desc}{RST}"
        clean = strip_ansi(line)
        pad = max(0, w - len(clean) - 1)
        print(f"{line}{' ' * pad}{C_PURPLE}│{RST}")

    print(f"{C_PURPLE}│{RST}")

    # Termux Commands - VERTICAL LISTING
    section_title2 = f"{BOLD}{C_GREEN}◆ TERMUX COMMANDS (from PATH){RST}"
    print(f"{C_PURPLE}│{RST} {section_title2}")
    print(f"{C_PURPLE}│{RST} {C_MGRAY}  Total: {len(cmds)} commands available{RST}")
    print(f"{C_PURPLE}│{RST}")

    max_cmd_len = max(len(c) for c in cmds) if cmds else 10
    col_width = max_cmd_len + 4
    num_cols = max(1, (w - 6) // col_width)
    rows = (len(cmds) + num_cols - 1) // num_cols

    for row in range(rows):
        line_parts = []
        for col in range(num_cols):
            idx = col * rows + row
            if idx < len(cmds):
                cmd = cmds[idx]
                line_parts.append(f"{C_GREEN}▸ {C_WHITE}{cmd:<{max_cmd_len}}{RST}")
            else:
                line_parts.append(" " * (max_cmd_len + 2))

        line = f"{C_PURPLE}│{RST}   " + f"{C_DGRAY} │ {RST}".join(line_parts)
        clean = strip_ansi(line)
        pad = max(0, w - len(clean) - 1)
        print(f"{line}{' ' * pad}{C_PURPLE}│{RST}")

    print(f"{C_PURPLE}┣{'━' * (w - 2)}┫{RST}")
    print(f"{C_PURPLE}│{RST} {C_MGRAY}[i] All Termux commands work normally{RST}")
    print(f"{C_PURPLE}│{RST} {C_MGRAY}[i] Counter resets every {max_commands} commands{RST}")
    print(f"{C_PURPLE}╰{'━' * (w - 2)}╯{RST}")
    print()

# ═══════════════════════════════════════════════════════════
# FIXED SYSTEM INFO - NO RAW ANSI
# ═══════════════════════════════════════════════════════════

def print_system_info():
    w = tw()

    print()
    print(f"{C_PURPLE}╭{'━' * (w - 2)}╮{RST}")

    header = f"{BOLD}{C_WHITE}SYSTEM ANALYSIS{RST}"
    sys.stdout.write(f"{C_PURPLE}│{RST} {header}")
    for _ in range(3):
        time.sleep(0.08)
        sys.stdout.write(f"{C_CYAN}.{RST}")
        sys.stdout.flush()
    print()

    print(f"{C_PURPLE}┣{'━' * (w - 2)}┫{RST}")

    # System Overview
    print(f"{C_PURPLE}│{RST} {BOLD}{C_SKY}◆ SYSTEM OVERVIEW{RST}")
    print(f"{C_PURPLE}│{RST}")

    os_val = get_os_info()[:35]
    device_val = get_device_name()
    shell_val = get_shell()
    uptime_val = get_uptime()

    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'OS':<10}{RST} {C_DGRAY}→{RST} {C_CYAN}{os_val}{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'DEVICE':<10}{RST} {C_DGRAY}→{RST} {C_CYAN}{device_val}{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'SHELL':<10}{RST} {C_DGRAY}→{RST} {C_CYAN}{shell_val}{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'UPTIME':<10}{RST} {C_DGRAY}→{RST} {C_CYAN}{uptime_val}{RST}")

    print(f"{C_PURPLE}│{RST}")

    # Hardware
    print(f"{C_PURPLE}│{RST} {BOLD}{C_SKY}◆ HARDWARE RESOURCES{RST}")
    print(f"{C_PURPLE}│{RST}")

    cpu = get_cpu()
    mem = get_mem()
    disk = get_disk_usage()

    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'CPU':<10}{RST} {C_DGRAY}→{RST} {C_WHITE}{cpu} (load){RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'RAM':<10}{RST} {C_DGRAY}→{RST} {C_WHITE}{int(mem)}% {draw_bar(mem, 25)}{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'DISK':<10}{RST} {C_DGRAY}→{RST} {C_WHITE}{int(disk)}% {draw_bar(disk, 25)}{RST}")

    print(f"{C_PURPLE}│{RST}")

    # Network
    print(f"{C_PURPLE}│{RST} {BOLD}{C_SKY}◆ NETWORK{RST}")
    print(f"{C_PURPLE}│{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'IP':<10}{RST} {C_DGRAY}→{RST} {C_WHITE}{get_ip()}{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'WIFI':<10}{RST} {C_DGRAY}→{RST} {C_WHITE}{get_wifi()[:30]}{RST}")

    # Power
    bat, bst = get_bat()
    if bat:
        print(f"{C_PURPLE}│{RST}")
        print(f"{C_PURPLE}│{RST} {BOLD}{C_SKY}◆ POWER{RST}")
        print(f"{C_PURPLE}│{RST}")
        status_icon = "⚡" if bst == "CHARGING" else "🔋"
        bat_color = C_GREEN if bat > 50 else C_GOLD if bat > 25 else C_ROSE
        print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'BATTERY':<10}{RST} {C_DGRAY}→{RST} {bat_color}{bat}% {status_icon} {bst}{RST}")

    print(f"{C_PURPLE}│{RST}")

    # Environment
    print(f"{C_PURPLE}│{RST} {BOLD}{C_SKY}◆ ENVIRONMENT{RST}")
    print(f"{C_PURPLE}│{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'PYTHON':<10}{RST} {C_DGRAY}→{RST} {C_WHITE}{sys.version.split()[0]}{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'COMMANDS':<10}{RST} {C_DGRAY}→{RST} {C_WHITE}{command_count}/{max_commands} ({int(command_percentage)}%){RST}")

    print(f"{C_PURPLE}╰{'━' * (w - 2)}╯{RST}")
    print()

# ═══════════════════════════════════════════════════════════
# ABOUT SCREEN
# ═══════════════════════════════════════════════════════════

def print_about():
    w = tw()

    print()
    print(f"{C_PURPLE}╭{'━' * (w - 2)}╮{RST}")

    title = f"{BOLD}{C_WHITE}ABOUT THE ARCHITECT{RST}"
    print(f"{C_PURPLE}│{RST} {center_text(title).strip()} {C_PURPLE}│{RST}")
    print(f"{C_PURPLE}┣{'━' * (w - 2)}┫{RST}")

    print(f"{C_PURPLE}│{RST} {BOLD}{C_CYAN}◆ CREATOR{RST}")
    print(f"{C_PURPLE}│{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'NAME':<12}{RST} {C_DGRAY}→{RST} {C_PINK}{BOLD}Farel Alfareza{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'ROLE':<12}{RST} {C_DGRAY}→{RST} {C_WHITE}Cyber Security Architect{RST}")
    print(f"{C_PURPLE}│{RST}")

    print(f"{C_PURPLE}│{RST} {BOLD}{C_CYAN}◆ SOCIAL{RST}")
    print(f"{C_PURPLE}│{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'GITHUB':<12}{RST} {C_DGRAY}→{RST} {C_PURPLE}fareldev-hub{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'STUDIO':<12}{RST} {C_DGRAY}→{RST} {C_PURPLE}ThePort Studio{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'TIKTOK':<12}{RST} {C_DGRAY}→{RST} {C_PURPLE}logic__vibes{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'PORTFOLIO':<12}{RST} {C_DGRAY}→{RST} {C_PURPLE}fareldev.vercel.app{RST}")
    print(f"{C_PURPLE}│{RST}")

    print(f"{C_PURPLE}│{RST} {BOLD}{C_CYAN}◆ PROJECT{RST}")
    print(f"{C_PURPLE}│{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'NAME':<12}{RST} {C_DGRAY}→{RST} {C_CYAN}{BOLD}ZyroXterm{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'TYPE':<12}{RST} {C_DGRAY}→{RST} {C_WHITE}Termux Visual Theme{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'VERSION':<12}{RST} {C_DGRAY}→{RST} {C_CYAN}{system_version}{RST}")
    print(f"{C_PURPLE}│{RST}   {C_DGRAY}├─{RST} {C_SKY}{'STATUS':<12}{RST} {C_DGRAY}→{RST} {C_GREEN}✓ Active{RST}")

    print(f"{C_PURPLE}┣{'━' * (w - 2)}┫{RST}")
    print(f"{C_PURPLE}│{RST} {C_MGRAY}[i] Style meets functionality - Termux reimagined{RST}")
    print(f"{C_PURPLE}│{RST} {C_MGRAY}[i] 100% Safe | No system files modified{RST}")
    print(f"{C_PURPLE}╰{'━' * (w - 2)}╯{RST}")
    print()

# ═══════════════════════════════════════════════════════════
# MAIN LOOP
# ═══════════════════════════════════════════════════════════

def main():
    global command_count, command_percentage
    reset_command_usage()

    draw_banner()
    draw_neofetch()

    welcome = f"{BOLD}{C_GREEN}WELCOME{RST}"
    hint = f"{C_MGRAY}Type {C_CYAN}help{C_MGRAY} for commands | total {max_commands} commands{RST}"

    print(center_text(welcome))
    print(center_text(hint))
    print()

    while True:
        try:
            create_prompt()
            cmd = input()

            if cmd.lower() in ["exit", "quit"]:
                print()
                print(f"{C_PURPLE}╭{'━' * (tw() - 2)}╮{RST}")
                goodbye = f"{BOLD}{C_CYAN}GOODBYE{RST}"
                print(f"{C_PURPLE}│{RST} {center_text(goodbye).strip()} {C_PURPLE}│{RST}")
                thanks = f"{C_MGRAY}Thanks for using ZyroXterm!{RST}"
                print(f"{C_PURPLE}│{RST} {center_text(thanks).strip()} {C_PURPLE}│{RST}")
                print(f"{C_PURPLE}╰{'━' * (tw() - 2)}╯{RST}")
                print()
                os.system("pkill -9 -u $(whoami)")
                break
            
            elif cmd.lower() == "help":
                print_help()
                
            elif cmd.lower() == "cmatrix":
                subprocess.Popen(f'{sys.executable} $HOME/ZyroXterm/theme/execute/cmatrix.py', shell=True)
            
            elif cmd.lower() == "deb install":
                os.system("chmod +x installer/debian.sh")
                os.system("bash $HOME/.ZyroXterm/theme/installer/debian.sh")
                
            elif cmd.lower() == "bun install":
                os.system("chmod +x installer/ubuntu.sh")
                os.system("bash $HOME/.ZyroXterm/theme/installer/ubuntu.sh")
                
            elif cmd.lower() == "arch install":
                os.system("chmod +x installer/arch.sh")
                os.system("bash $HOME/.ZyroXterm/theme/installer/arch.sh")
                
            elif cmd.lower() == "debian run":
                os.system("bash $HOME/debian.sh")
                
            elif cmd.lower() == "ubuntu run":
                os.system("bash $HOME/ubuntu.sh")
                
            elif cmd.lower() == "arch run":
                os.system("bash $HOME/arch.sh")
                
            elif cmd.lower() == "uninstall":
                os.system("bash $HOME/.ZyroXterm/uninstall.sh")
            
            elif cmd.lower() == "restart":
                draw_banner()
                draw_neofetch()

            elif cmd.lower() in ["sys", "system info", "info"]:
                print_system_info()

            elif cmd.lower() == "about":
                print_about()

            elif cmd.lower() == "reset":
                reset_command_usage()
                print(f"{C_GREEN}✓ Command counter reset to 0%{RST}")
                print()

            elif cmd.strip() == "":
                continue

            else:
                if cmd.startswith("cd "):
                    try:
                        dir_path = cmd[3:].strip()
                        if dir_path in ["$HOME", "~"]:
                            dir_path = os.environ.get("HOME", "/data/data/com.termux/files/home")
                        os.chdir(dir_path)
                    except Exception as e:
                        print(f"{C_ROSE}✗ Error: {e}{RST}")
                else:
                    exit_code = os.system(cmd)

                if cmd.lower() not in ["clear", "help", "sys", "system info", "info", "about", "reset"]:
                    update_command_usage()

                print(f"{C_DGRAY}{'─' * tw()}{RST}")

        except KeyboardInterrupt:
            print(f"\n{C_GOLD}⚠ Press 'exit' to quit{RST}")
        except EOFError:
            break
        except Exception as e:
            print(f"{C_ROSE}✗ Error: {e}{RST}")

if __name__ == "__main__":
    if not os.path.exists("/data/data/com.termux"):
        print(f"{C_GOLD}⚠ Warning: Running outside Termux{RST}")
        time.sleep(1)

        print(f"{C_GOLD}⚠ Warning: Running outside Termux{RST}")
        time.sleep(1)

    main()