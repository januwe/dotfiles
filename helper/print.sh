# symbols from http://panmental.de/symbols/info.htm

BOLD=$(tput bold)
RESET=$(tput sgr0)

info() {
	local yellow=$(tput setaf 11)
	echo -e "${BOLD}${yellow}[ ! ]${RESET} - ${yellow}$@${RESET}"
}

success() {
	local green=$(tput setaf 51)
	echo -e "${BOLD}${green}[ ✓ ]${RESET} - ${green}$@${RESET}"
}

error() {
	local	red=$(tput setaf 197)
	echo -e "${BOLD}${red}[ ✗ ]${RESET} - ${red}$@${RESET}"
}

die() {
	local	red=$(tput setaf 197)
	echo -e "${BOLD}${red}[ ✗ ]${RESET} - ${red}$@${RESET}" >&2
	exit 1
}
