# Create directory and change into it

function mcd() {
	mkdir -p "$@" && cd "$@";
}
