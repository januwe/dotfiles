#!/usr/bin/env bash


# info "Checking for root..."
if [[ ${EUID} -ne 0 ]]; then
	die "This script needs to be run as root! Exiting..."
fi

# install dependencies
install_deps() {
	clear
	# info "Installing needed dependencies!"
	gum style --foreground 14 "Installing needed dependencies!"
	sleep 1

	# get path to binaries
	local dpkg_bin=$(command -v dpkg)
	local apt_bin=$(command -v apt)

	# verify function
	is_installed() {
		${dpkg_bin} -s "$1" >/dev/null 2>&1
	}

	# list of dependencies
	local deps=(
			git jq terminator zsh
	)

	# info "Checking for required packages..."
	# sleep 2
	gum spin --spinner dot --title "Checking for required packages..." -- sleep 2

	# get missing packages
	local missing_pkgs=()
	for pkg in "${deps[@]}"; do
		if ! is_installed "$pkg"; then
			missing_pkgs+=("$pkg")
			error "${pkg} is not installed."
		else
			info "${pkg} already installed."
		fi
	done

	# Install all misising packages
	if ((${#missing_pkgs[@]} > 0)); then
		# info "Installing ${#missing_pkgs[@]} packages..."
		gum spin --spinner dot --title "Installing ${#missing_pkgs[@]} packages..." -- sleep 2.5
		if sudo ${apt_bin} install --no-install-recommends -y "${missing_pkgs[@]}" &>/dev/null; then
			# verify complete installation
			local failed=()
			for pkg in "${deps[@]}"; do
				if ! is_installed "$pkg"; then
					failed+=("$pkg")
					error "Failed to install: $pkg"
				fi
			done
		else
			die "Installation failed! Check apt log for details."
		fi

		gum style --foreground 212 "All packages installed!"
	else
		success "All dependencies are already installed!"
	fi
}

# initial_requirements
# install_deps

# helper functions
# copy zshrc
# copy configs, functions, binaries and aliases
# i3 config
# clone github repos
install_repos() {

	get_download_url() {
		local github_user="$1"
		local github_pkg="$2"
		local pkg_arch="$3"
		local github_api="https://api.github.com/repos/"

		latest_url="${github_api}${github_user}/${github_pkg}/releases/latest"
		wget -q -O - "${latest_url}" | jq -r '.assets[] | select(.name | contains ("'"${pkg_arch}"'")) | .browser_download_url'
	}

	fzf_download=$(get_download_url "junegunn" "fzf" "linux_amd64")
	# fzf_download=$(get_download_url "junegunn" "fzf" "linux_amd64")
}

install_repos
# install cht.sh - https://github.com/chubin/cheat.sh
