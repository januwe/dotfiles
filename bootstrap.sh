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
if ! command -v gum &>/dev/null; then
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

# file already exists handling
exists_handling() {
    local dst=$1 ans=$2

	if [ -z $ans ]; then
		ans="s"
	fi

    file=$(basename "$dst")
	case $ans in
		"s" ) info "Skipping ${file}."; sleep 0.5; return 100;;
		"b" ) info "Backing up ${file} to ${file}.bak." && /usr/bin/mv "${dst}"{,.bak}; sleep 0.5; return 200 ;;
		"r" ) info "Deleting ${file}." && /usr/bin/rm -f "${dst}" 2>/dev/null; sleep 0.5; return 200 ;;
        * ) die "No valid answer! Use s,b or r. (default: skip) Exiting..."
	esac

}

# installing dotfiles (linking files)
### all files ending with .symlink containing src:dest
symlink_file() {
	local src=$1 dst=$2

    local file="" skip
	# check if dst file already exists 
	if [ -e $dst ]; then
        info "${dst} already exists..."
        # ask if skip, backup or remove
        read -p "$(user "Do you want to [s]kip, [b]ackup or [r]emove ${dst}? ")" answer < /dev/tty

        exists_handling "$dst" "$answer"
	fi

    if [ $? -ne 100 ]; then
        file=$(basename "$src")
        info "Creating symlink for $file" && sleep 0.5
        ln -s "$src" "$dst" && success "linked $src to $dst"
    fi
}

copy_dir() {
	local src=$1 orgdst=$2

    local dir=$(basename "$src")
    local dst="$orgdst/$dir"
	# check if dst file already exists 
	if [ -e $dst ]; then
        info "${dst} already exists... Skipping."
        # ask if skip, backup or remove
        read -p "$(user "Do you want to [s]kip, [b]ackup or [r]emove ${dst}? ")" answer < /dev/tty

        exists_handling "$dst" "$answer"
    fi

    if [ $? -ne 100 ]; then
        info "Copying $dir to $orgdst" && sleep 1
        cp -R "$src" "$orgdst" && success "Copied $dir to $orgdst"
	fi
}

copy_file() {
	local src=$1 orgdst=$2

    local file=$(basename "$src")
    local dst="$orgdst/$file"
	# check if dst file already exists 
	if [ -e $dst ]; then
        info "${dst} already exists... Skipping."
        # ask if skip, backup or remove
        read -p "$(user "Do you want to [s]kip, [b]ackup or [r]emove ${dst}? ")" answer < /dev/tty

        exists_handling "$dst" "$answer"
    fi

    if [ $? -ne 100 ]; then
        info "Copying $file to $orgdst" && sleep 1
        cp "$src" "$orgdst" && success "Copied $file to $orgdst"
	fi
}

install_dotfiles() {
	clear
	info "Installing dotfiles\n" && sleep 1

    info "Symlinking files..."
	find -H "$DOTFILES" -maxdepth 2 -name '*.symlink' -not -path '*.git*' | while read linkfile
	do
		cat "$linkfile" | while read line
		do
			local src dst dir
			src=$(eval echo "$line" | cut -d":" -f1)
			dst=$(eval echo "$line" | cut -d":" -f2)
			dir=$(dirname $dst)

			if ! [ -d $dir ]; then
				info "Creating $dir ..." && mkdir -p "$dir" && sleep 0.5
			fi

			symlink_file "$src" "$dst"
		done
	done

    echo ''
    info "Copying config files..."
    for confdir in $(find -H "$DOTFILES" -maxdepth 2 -name 'config' -not -path '*.git*');
    do
        local dir dst name

        dir=$(dirname $confdir)
        name=$(echo "$dir" | sed 's|.*/||')
        dst="$HOME/.config/$name"
        if ! [ -d $dst ]; then
		    info "Creating $dst ..." && mkdir -p "$dst" && sleep 0.5
        fi

        for file in $(find -H "$confdir" -maxdepth 1 | tail -n+2);
        do
            # copy files
            if [ -d $file ]; then
                copy_dir "$file" "$dst"
            else
                copy_file "$file" "$dst"
            fi
        done
    done

    # Replace DOTFILES var in ~/.zshrc
    /usr/bin/sed -ri "s/^(export DOTFILES=\")(.*?)(\")$/\1$DOTFILES\3/" "$HOME/.zshrc"
}

install_dotfiles
