import random
import shutil
import sys
import time
import os
import signal
import pyfiglet

RST   = "\033[0m"
BOLD  = "\033[1m"
DIM   = "\033[2m"

C_BLACK   = "\033[38;5;232m"
C_DGRAY   = "\033[38;5;235m"
C_MGRAY   = "\033[38;5;245m"
C_LGRAY   = "\033[38;5;250m"
C_WHITE   = "\033[38;5;255m"

C_DEEP    = "\033[38;5;17m"
C_NAVY    = "\033[38;5;18m"
C_DBLUE   = "\033[38;5;19m"
C_BLUE    = "\033[38;5;21m"
C_MBLUE   = "\033[38;5;27m"
C_SKY     = "\033[38;5;33m"
C_CYAN    = "\033[38;5;39m"
C_AZURE   = "\033[38;5;45m"
C_ICE     = "\033[38;5;51m"
C_GLOW    = "\033[38;5;87m"

BG_DEEP   = "\033[48;5;17m"
BG_NAVY   = "\033[48;5;18m"
BG_DBLUE  = "\033[48;5;19m"
BG_BLUE   = "\033[48;5;21m"
BG_MBLUE  = "\033[48;5;27m"
BG_SKY    = "\033[48;5;33m"
BG_CYAN   = "\033[48;5;39m"
BG_AZURE  = "\033[48;5;45m"
BG_ICE    = "\033[48;5;51m"

colors = [
    C_DEEP, C_NAVY, C_DBLUE, C_BLUE, C_MBLUE,
    C_SKY, C_CYAN, C_AZURE, C_ICE, C_GLOW
]

glow_colors = [C_AZURE, C_ICE, C_GLOW, C_WHITE]

dark_colors = [C_BLACK, C_DGRAY, C_MGRAY]

katakana = list(
    "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
    "abcdefghijklmnopqrstuvwxyz"
    "0123456789"
    "!@#$%^&*()_+-=[]{}|;':\",./<>?"
    "αβγδεζηθικλμνξοπρστυφχψω"
    "∞∑∆∇∂∫√≈≠≤≥"
)

# Flag untuk exit
running = True

def signal_handler(sig, frame):
    global running
    running = False
    print("\n")
    
def get_terminal_size():
    try:
        size = shutil.get_terminal_size()
        return size.columns, size.lines
    except:
        return 80, 24

def clear():
    os.system("clear" if os.name != "nt" else "cls")

def hide_cursor():
    sys.stdout.write("\033[?25l")
    sys.stdout.flush()

def show_cursor():
    sys.stdout.write("\033[?25h")
    sys.stdout.flush()

def move_cursor(row, col):
    sys.stdout.write(f"\033[{row};{col}H")
    sys.stdout.flush()

def draw_banner():
    logo = pyfiglet.figlet_format("ZyroXterm", width=100)
    print(logo)

def clear_screen_area():
    cols, rows = get_terminal_size()
    for r in range(1, rows + 1):
        move_cursor(r, 1)
        sys.stdout.write(" " * cols)
    sys.stdout.flush()

def draw_rain(cols, rows, drops):
    global running
    
    # Bersihkan area untuk animasi baru (tidak scrolling)
    for r in range(1, rows + 1):
        move_cursor(r, 1)
        sys.stdout.write(" " * cols)
    
    # Buat drops baru di posisi acak
    for c in range(cols):
        if random.random() < 0.05 and c not in drops:
            drops[c] = {
                "row": 0,
                "speed": random.choice([1, 2]),
                "length": random.randint(5, min(15, rows - 2)),
                "bright": random.random() < 0.2,
                "glitch": random.random() < 0.1,
                "active": True
            }
    
    # Update dan gambar setiap drop
    to_delete = []
    for c, drop in drops.items():
        if not drop["active"]:
            to_delete.append(c)
            continue
            
        head = drop["row"]
        length = drop["length"]
        bright = drop["bright"]
        glitch = drop["glitch"]
        
        # Gambar dari atas ke bawah
        for offset in range(length):
            r = head - offset
            if 1 <= r <= rows and c + 1 <= cols:
                char = random.choice(katakana)
                
                # Warna berdasarkan posisi (gradient dari atas ke bawah)
                if offset == 0:  # Head (paling depan)
                    color = C_WHITE if bright else C_GLOW
                    if glitch and random.random() < 0.2:
                        char = random.choice(["█", "▓", "▒", "◆"])
                elif offset == 1:
                    color = C_ICE
                elif offset == 2:
                    color = C_AZURE
                elif offset == 3:
                    color = C_CYAN
                elif offset == 4:
                    color = C_SKY
                elif offset <= 7:
                    color = C_MBLUE
                elif offset <= 10:
                    color = C_BLUE
                else:
                    color = C_DBLUE
                
                move_cursor(r, c + 1)
                if bright and offset == 0:
                    sys.stdout.write(f"{BOLD}{color}{char}{RST}")
                else:
                    sys.stdout.write(f"{color}{char}{RST}")
        
        # Gerakkan drop ke bawah
        drop["row"] += drop["speed"]
        
        # Hapus jika sudah melewati batas
        if head - length > rows:
            to_delete.append(c)
    
    # Hapus drops yang sudah selesai
    for c in to_delete:
        del drops[c]
    
    sys.stdout.flush()

def draw_scanline(cols, rows):
    # Efek scanline horizontal
    scan_pos = int(time.time() * 10) % rows
    move_cursor(scan_pos, 1)
    sys.stdout.write(f"{DIM}{C_DEEP}{'─' * cols}{RST}")
    sys.stdout.flush()

def draw_glitch(cols, rows, drops):
    # Efek glitch acak
    if random.random() < 0.03:
        glitch_row = random.randint(1, max(1, rows - 5))
        glitch_col = random.randint(1, max(1, cols - 10))
        glitch_text = "".join(random.choice(katakana) for _ in range(random.randint(3, 8)))
        color = random.choice([C_GLOW, C_ICE, C_WHITE])
        move_cursor(glitch_row, glitch_col)
        sys.stdout.write(f"{BOLD}{color}{glitch_text}{RST}")
        time.sleep(0.05)
        # Bersihkan glitch
        move_cursor(glitch_row, glitch_col)
        sys.stdout.write(" " * len(glitch_text))
        sys.stdout.flush()

def draw_status_bar(cols, rows, mode, fps, drops_count):
    bar = f" {C_MBLUE}◆{RST} {C_SKY}CMATRIX{RST} {C_DBLUE}│{RST} {C_CYAN}[{mode.upper()}]{RST} {C_DBLUE}│{RST} {C_CYAN}Drops:{drops_count}{RST} {C_DBLUE}│{RST} {C_CYAN}FPS:{fps}{RST} {C_DBLUE}│{RST} {C_MGRAY}[CTRL+C] Exit{RST} "
    
    # Calculate clean length without ANSI codes
    clean_bar = bar.replace("\033[38;5;", "").replace("\033[48;5;", "").replace("\033[0m", "").replace("\033[1m", "").replace("\033[2m", "")
    clean_len = len(clean_bar)
    pad = max(0, cols - clean_len - 2)
    
    if rows >= 1:
        move_cursor(rows, 1)
        sys.stdout.write(f"{C_BLACK}{' ' * cols}{RST}")
        move_cursor(rows, 1)
        sys.stdout.write(f"{C_DBLUE}{'─' * cols}{RST}")
        move_cursor(rows, 1)
        sys.stdout.write(bar + " " * pad)
        sys.stdout.flush()

def main():
    global running
    
    # Setup signal handler untuk CTRL+C
    signal.signal(signal.SIGINT, signal_handler)
    
    clear()
    hide_cursor()

    cols, rows = get_terminal_size()
    cols = min(cols, 200)
    rows = min(rows, 60)

    draw_banner()
    clear_screen_area()

    drops = {}
    mode = "rain"
    frame_count = 0
    last_time = time.time()
    fps = 0
    last_scanline = 0
    
    try:
        while running:
            cols, rows = get_terminal_size()
            cols = min(cols, 200)
            rows = min(rows, 60)
            
            # Gambar efek berdasarkan mode
            if mode == "rain":
                draw_rain(cols, rows - 1, drops)
            elif mode == "scanline":
                draw_rain(cols, rows - 1, drops)
                if time.time() - last_scanline > 0.05:
                    draw_scanline(cols, rows - 1)
                    last_scanline = time.time()
            elif mode == "glitch":
                draw_rain(cols, rows - 1, drops)
                draw_glitch(cols, rows - 1, drops)
            
            # Hitung FPS
            frame_count += 1
            now = time.time()
            if now - last_time >= 1.0:
                fps = frame_count
                frame_count = 0
                last_time = now
            
            # Gambar status bar
            draw_status_bar(cols, rows, mode, fps, len(drops))
            
            # Kontrol kecepatan frame
            time.sleep(0.033)  # ~30 FPS
    
    except KeyboardInterrupt:
        pass
    finally:
        show_cursor()
        clear()
        cols, rows = get_terminal_size()
        
        # Pesan exit
        exit_msg = f"\n{C_SKY}╔{'═' * 48}╗{RST}\n"
        exit_msg += f"{C_SKY}║{RST} {C_GLOW}CMATRIX TERMINATED OUT {RST} {C_SKY}║{RST}\n"
        exit_msg += f"{C_SKY}╚{'═' * 48}╝{RST}\n"
        exit_msg += f"{C_SKY}◆{RST} {C_MGRAY}Program exited cleanly{RST}\n"
        
        sys.stdout.write(exit_msg)
        sys.stdout.flush()
        time.sleep(1)

if __name__ == "__main__":
    main()