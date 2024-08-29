#!/bin/sh
# Unlicensed under the https://unlicense.org/.
# vi: set ts=2 noet:
# shellcheck enable=check-set-e-suppressed

set -eu
fail() {
	fail1 "$0:" "$@"
}
fail1() {
	echo "$@"
	return 1
}

# Untrusted, but I can't bother
env_load() {
	[ "$#" -ne 1 ] && cat >"./_tmp/env_load" && ARG="./_tmp/env_load" || ARG="$1"
	set -a
	# shellcheck source=/dev/null
	. "$ARG"
	set +a
	rm -f './_tmp/env_load'
}
env_require() {
	[ "$#" -ne 1 ] && return 2
	# shellcheck disable=SC2013
	for arg in $(cat); do
		ARG_VAL=$(eval echo "\"\${$arg:-}\"")
		[ -n "$ARG_VAL" ] || fail1 "$1: Argument \"$arg\" is required to be set and non-empty"
	done
}

justify() {
	[ "$#" -ne 2 ] && return 2

	curr=""
	# shellcheck disable=SC2013
	for arg in $(cat); do
		if [ -z "$curr" ]; then
			curr="$arg"
		elif [ "$1" -gt $(("${#curr}" + "${#arg}")) ]; then
			curr="$curr $arg"
		else
			echo "$2$curr"
			curr="$arg"
		fi
	done
	echo "$2$curr"
}

substitute() {
	[ "$#" -ne 1 ] && return 2
	OLD_NAME="$1"
	if [ -d "$1" ]; then
		for subchild in "$1"/*; do # "$1"/.*; do
			#	[ "$subchild" = "$1"/.'*' ] && continue
			[ "$subchild" = "$1"/'*' ] && continue
			substitute "$subchild" "$2"
		done
		return 0
	fi
	[ -f "$1" ] || return 3

	case $(basename "$OLD_NAME") in
	*'@')
		true
		;;
	*)
		return 0
		;;
	esac
	rm -f ./_tmp/substitute

	GUARD=0
	SUB_MODE=
	PIPELINE="cat"
	while IFS= read -r line; do
		case "$line" in
		'@'*)
			[ "$GUARD" = 0 ] && SUB_MODE="${line#"@"}"
			[ "$GUARD" = 1 ] && GUARD=2 && continue
			[ "$GUARD" = 0 ] && GUARD=1
			;;
		'|#'*)
			[ "$GUARD" = 0 ] && GUARD=1
			;;
		'|'*)
			[ "$GUARD" = 0 ] && GUARD=1
			[ "$GUARD" = 1 ] && PIPELINE="$PIPELINE | (${line#"|"})"
			;;
		*)
			GUARD=2
			;;
		esac
		[ "$GUARD" = 2 ] && echo "$line" >>./_tmp/substitute
	done <"$OLD_NAME"

	SUB_MODE="$(echo "$SUB_MODE" | sed -e 's/^ *//' -e 's/ *$//') "
	NEW_NAME=$(eval "echo ${SUB_MODE#* }")
	SUB_MODE="${SUB_MODE%% *}"

	NEW_NAME=$(echo "$NEW_NAME" | sed -e 's/^ *//' -e 's/ *$//')

	[ -z "$SUB_MODE" ] && SUB_MODE="fail"
	[ -n "$NEW_NAME" ] && NEW_NAME="$(dirname "$OLD_NAME")/$NEW_NAME"
	[ -z "$NEW_NAME" ] && NEW_NAME="${OLD_NAME%"@"}"
	#shellcheck disable=SC2086
	if [ -f "$NEW_NAME" ]; then
		case "$SUB_MODE" in
		fail | 'fail!')
			echo "substitute: File exists ($SUB_MODE): $NEW_NAME"
			rm ./_tmp/substitute
			return 1
			;;
		override | 'override!')
			sh -xc "$PIPELINE" <./_tmp/substitute >"$NEW_NAME"
			rm ./_tmp/substitute
			return 0
			;;
		append | 'append!')
			sh -xc "$PIPELINE" <./_tmp/substitute >>"$NEW_NAME"
			rm ./_tmp/substitute
			return 0
			;;
		transform | 'transform!' | 'transform?')
			mv -f "$NEW_NAME" ./_tmp/substitute
			sh -xc "$PIPELINE" <./_tmp/substitute >"$NEW_NAME"
			rm ./_tmp/substitute
			return 0
			;;
		nothing | 'nothing!')
			rm ./_tmp/substitute
			return 0
			;;
		*)
			echo "substitute: Invalid mode: $1"
			echo "substitute: Allowed modes:"
			echo "fail fail! override override! append append! transform transform? transform! nothing nothing!" | justify 50 "substitute:   "
			return 1
			;;
		esac
	else
		case "$SUB_MODE" in
		'fail!' | 'override!' | 'append!' | 'transform!' | 'nothing!')
			echo "substitute: File doesn't exist ($SUB_MODE): $NEW_NAME"
			rm ./_tmp/substitute
			return 1
			;;
		'transform?')
			mv ./_tmp/substitute "$NEW_NAME"
			return 0
			;;
		fail | override | append | transform | nothing)
			sh -xc "$PIPELINE" <./_tmp/substitute >"$NEW_NAME"
			rm ./_tmp/substitute
			return 0
			;;
		*)
			echo "substitute: Invalid mode: $1"
			echo "substitute: Allowed modes:"
			echo "fail fail! override override! append append! transform transform? transform! nothing nothing!" | justify 50 "substitute:   "
			return 1
			;;
		esac
	fi
}

merge_dir() {
	[ "$#" -ne 2 ] && return 2
	for subchild in "$2"/*; do # "$2"/.*; do
		# [ "$subchild" = "$2"/.'*' ] && continue
		[ "$subchild" = "$2"/'*' ] && continue
		BASENAME=$(basename "$subchild")
		if [ -d "$subchild" ]; then
			[ -e "$1/$BASENAME" ] && fail1 "merge_dir: Cannot override $1/$BASENAME"
			mkdir -p "$1/$BASENAME"
			merge_dir "$1/$BASENAME" "$2/$BASENAME"
		fi
		if [ -f "$subchild" ]; then
			[ -e "$1/$BASENAME" ] && fail1 "merge_dir: Cannot override $1/$BASENAME"
			mv "$subchild" "$1/$BASENAME"
		fi
	done
	rmdir "$2"
}

check_env() {
	if command -v git >/dev/null; then
		[ "$(pwd)" = "$(git rev-parse --show-toplevel)" ] || fail "Must be run from root contest directory"
		# People are scared of rebase and litter merge commits
		git config pull.rebase true
		# Add additional checks to the contest commits
		git config core.hooksPath .githooks
	fi
}

check_env

mkdir -p ./_tmp

env_load ./config.env

env_require './config.env' <<EOF
CONTESTID CONTESTNAME
EOF

cat >./_tmp/new-package-settings.env <<EOF
# Task ID, must be 3 lowercase ASCII letters
ID=
# Human readable name, as shown in the task statement
NAME=
# Name of the task template to use. The available templates are:
$(find ./_templates/* -prune -type d -exec basename {} ';' | grep -vE '^_.*$' | justify 60 '#> ')
TEMPLATE=standard
# Name of the additional libraries to include. Available are:
$(find ./_templates/_lib/* -prune -type d -exec basename {} ';' | justify 60 '#> ')
LIBRARIES='oi testgen'
# Whether to include the local template. Should usually be true.
LOCAL=true
# Default RAM limit, in megabytes. Can change manually later.
MEMORY=512
# Default time limit, in whole seconds. Can change manually later.
TIME=2
# Default number of subtasks to generate. Can change manually later.
SUBTASKS=4
EOF

${EDITOR:-nano} "./_tmp/new-package-settings.env"
env_load <"./_tmp/new-package-settings.env"

env_require './new-package.sh' <<EOF
ID NAME TEMPLATE
EOF

export LOCAL="${LOCAL:-true}"
export MEMORY="${MEMORY:-512}"
export MEMORY_KB=$((MEMORY * 1024))
TIME="$(printf "%.3f" "${TIME:-2}")"
export TIME
TIME_MS=$(echo "$TIME" | tr -d ".")
export TIME_MS
export LIBRARIES="${LIBRARIES:-}"
export SUBTASKS="${SUBTASKS:-4}"

export TASKID="$ID"
export TASKNAME="$NAME"
export S="$" # Used for trickery w/envsubst

echo "$TASKID" | grep -qE "^[a-z]{3}$" || fail "Invalid ID: \"$TASKID\""
templates="${TEMPLATE:-unreachable_error}"
[ "$LOCAL" = "true" ] && templates="$templates _local"
for lib in $LIBRARIES; do
	templates="$templates _lib/$lib"
	true
done

RESOLVED_TEMPLATES=" "
APPLIED_TEMPLATES=" "
apply_template() {
	if [ -d "./_templates/$1" ]; then
		case "$1" in
		_lib/*)
			fail1 "template: Unknown library: ${1#'_lib/'}"
			;;
		_local)
			echo "template: _local template doesn't exist. Skipping."
			return 0
			;;
		*)
			fail1 "template: Unknown template: $1"
			;;
		esac
	fi

	case "$APPLIED_TEMPLATES" in
	*" $1 "*)
		echo "template: Template $1 already applied"
		return 0
		;;
	*)
		echo "template: Resolving $1..."
		;;
	esac
	case "$RESOLVED_TEMPLATES" in
	*" $1 "*)
		echo "template: Failed resolution due to a dependency loop."
		return 1
		;;
	*)
		true
		;;
	esac

	RESOLVED_TEMPLATES="$RESOLVED_TEMPLATES$1 "
	if [ -f "./_templates/$1/_extend" ]; then
		echo "template: Resolving dependencies for $1..."
		while IFS= read -r extend; do
			apply_template "$(dirname "./_templates/$1")/$extend"
		done <"./_templates/$1/_extend"
	fi
	echo "template: Applying $1..."
	cp -RL "./_templates/$1" "./_tmp/_copy"
	rm -f "./_tmp/copy/_extend"
	merge_dir "./_tmp/$TASKID" "./_tmp/_copy"
	substitute "./_tmp/$TASKID"
	echo "template: Applied $1"
	APPLIED_TEMPLATES="$APPLIED_TEMPLATES$1 "
}

rm -rf "./_tmp/_copy"
rm -rf "./_tmp/$TASKID"
mkdir -p "./_tmp/$TASKID"
for template in $templates; do
	apply_template "$template"
done

mv "./_tmp/$TASKID" "./$TASKID"

echo "Created new task in ./$TASKID"
exit 0
