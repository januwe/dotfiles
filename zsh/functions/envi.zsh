# Load environment variables from .env file

function envi() {
	if [ -f .env ]; then
		export $(sed '/^[[:blank:]]*#/d;s/[[:blank:]]*#.*//' .env)
	else
		echo 'No .env file found' 1>&2
		return 1
	fi
}
