# Get latest release from github url, example https://github.com/<USER>/<REPO>
# https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c

function git_latest_release() {
	local url="$1"
	git ls-remote --refs --sort="version:refname" --tags $url | cut -d/ -f3- | tail -n1
}
