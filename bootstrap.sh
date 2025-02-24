#!/usr/bin/env bash

clear
# cd into dotfiles dir
# cd "$(dirname "$0")/.."
cd "$(dirname "$0")/"
DOTFILES=$(pwd -P)

### PRINT WELCOME ###
### END WELCOME ###

### START PRINT HELPER ###
BOLD=$(tput bold)
RESET=$(tput sgr0)

info() {
	local yellow=$(tput setaf 11)
	printf "\r [ ${BOLD}${yellow}::${RESET} ] ${BOLD}${yellow}-${RESET} $@\n"
}

user() {
	local blue=$(tput setaf 39)
	printf "\r [ ${BOLD}${blue}??${RESET} ] ${BOLD}${blue}-${RESET} $@\n"
}

success() {
	local green=$(tput setaf 14)
	printf "\r [ ${BOLD}${green}✓${RESET}  ] ${BOLD}${green}-${RESET} $@\n"
}

error() {
	local	red=$(tput setaf 197)
	printf "\r [ ${BOLD}${red}✗${RESET}  ] ${BOLD}${red}-${RESET} $@\n"
}

die() {
	local	red=$(tput setaf 197)
	printf "\r [ ${BOLD}${red}✗${RESET}  ] ${BOLD}${red}-${RESET} $@" >&2
	exit 1
}
### END PRINT HELPER ###

install_gum() {
	# TODO: install gum :lul:
	success "Gum installed!"
}

# check for gum here
info "Checking if gum is installed..." && sleep 0.5
if ! command -v guma &>/dev/null; then
	error "gum is not installed!"
	read -p "$(user "Do want me to install gum? [Y/n]: ")" answer

	if [ -z $answer ]; then
		answer="y"
	fi

	case $answer in
		[Yy] ) info "Installing gum!" && sleep 0.5; install_gum ;;
		[Nn] ) error "Gum will not be installed. Please consider installing it manually, for best experience. :lul: Install script may break!" && sleep 2 ;;
		* ) die "No valid answer! Use Y,y,<Enter> or N,n! Exiting..."
	esac
fi

# installing dotfiles (linking files)
### all files ending with .symlink containing src:dest
symlink_file() {
	local src=$1 dst=$2

	local skip
	# check if dst file already exists and ask what to do
	if [ -h "$dst" ] || [ -f "$dst" ] || [ -d "$dst" ]; then
		local src_current="$(readlink $dst)"

		# skip if dst file is a symlink already
		if ! [ "$src_current" == "$dst" ]; then
			# ask what to do, overwrite || skip || backup
			info "Something for future uwe."
		fi
	fi

	# link file if skip is empty or "false"
	if ! [ "$skip" == "true" ]; then
		# ln -s "$src" "$dst"
		success "linked $src to $dst"
	fi
}

install_dotfiles() {
	clear
	info "Installing dotfiles" && sleep 1

	find -H "$DOTFILES" -maxdepth 2 -name '*.symlink' -not -path '*.git*' | while read linkfile
	do
		cat "$linkfile" | while read line
		do
			local src dst dir
			src=$(eval echo "$line" | cut -d":" -f1)
			dst=$(eval echo "$line" | cut -d":" -f2)
			dir=$(dirname $dst)

			if ! [ -d $dir ]; then
				# info "Creating $dir ..." && mkdir -p "$dir"
				info "$dir"
			fi

			symlink_file "$src" "$dst"
		done
	done
}


# create env file

### TESTING ###
# info "ThIs Is A tEsT!"
# error "Test ERRRRRRRRRRRRRROR!"
# success "Yay, it works!"
# die "Died."
install_dotfiles
