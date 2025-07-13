#!/bin/sh
# Unlicensed under the https://unlicense.org/.
# vi: set ts=2 noet:
# shellcheck enable=check-set-e-suppressed

set -eu
fail() {
	fail1 "$0:" "$@"
}
fail1() {
	bold "$@"
	return 1
}
bold() {
	if command -v tput >/dev/null; then
		TPUT="tput"
	else
		TPUT="true"
	fi

	"$TPUT" bold
	echo "$@"
	"$TPUT" sgr0
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
		elif [ "$1" -gt $((${#curr} + ${#arg})) ]; then
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
		for subchild in "$1"/* "$1"/.*; do
			[ "$subchild" = "$1"/.'*' ] && continue
			[ "$subchild" = "$1"/'*' ] && continue
			[ "$subchild" = "$1"/. ] && continue
			[ "$subchild" = "$1"/.. ] && continue
			substitute "$subchild"
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
	rm -f ./_tmp/substitute.sh
	touch ./_tmp/substitute

	GUARD=0
	SUB_MODE=
	while IFS= read -r line; do
		case "$line" in
		'@'*)
			[ "$GUARD" = 0 ] && SUB_MODE="${line#"@"}"
			[ "$GUARD" = 1 ] && GUARD=2 && continue
			[ "$GUARD" = 0 ] && GUARD=1
			;;
		'|'*)
			[ "$GUARD" = 0 ] && GUARD=1
			[ "$GUARD" = 1 ] && printf "%s\n" "${line#"|"}" >>./_tmp/substitute.sh
			;;
		*)
			GUARD=2
			;;
		esac
		[ "$GUARD" = 2 ] && printf "%s\n" "$line" >>./_tmp/substitute
	done <"$OLD_NAME"

	[ -f ./_tmp/substitute.sh ] || echo "cat" >./_tmp/substitute.sh

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
			bold "substitute: File exists ($SUB_MODE): $NEW_NAME"
			rm ./_tmp/substitute ./_tmp/substitute.sh
			return 1
			;;
		override | 'override!')
			sh -ex ./_tmp/substitute.sh <./_tmp/substitute >"$NEW_NAME"
			rm ./_tmp/substitute ./_tmp/substitute.sh "$OLD_NAME"
			return 0
			;;
		append | 'append!')
			sh -ex ./_tmp/substitute.sh <./_tmp/substitute >>"$NEW_NAME"
			rm ./_tmp/substitute ./_tmp/substitute.sh "$OLD_NAME"
			return 0
			;;
		transform | 'transform!' | 'transform?')
			mv -f "$NEW_NAME" ./_tmp/substitute
			sh -ex ./_tmp/substitute.sh <./_tmp/substitute >"$NEW_NAME"
			rm ./_tmp/substitute ./_tmp/substitute.sh "$OLD_NAME"
			return 0
			;;
		nothing | 'nothing!')
			rm ./_tmp/substitute ./_tmp/substitute.sh "$OLD_NAME"
			return 0
			;;
		*)
			bold "substitute: Invalid mode: $1"
			bold "substitute: Allowed modes:"
			bold "fail fail! override override! append append! transform transform? transform! nothing nothing!" | justify 50 "substitute:   "
			return 1
			;;
		esac
	else
		case "$SUB_MODE" in
		'fail!' | 'override!' | 'append!' | 'transform!' | 'nothing!')
			bold "substitute: File doesn't exist ($SUB_MODE): $NEW_NAME"
			rm ./_tmp/substitute ./_tmp/substitute.sh
			return 1
			;;
		'transform?')
			mv ./_tmp/substitute "$NEW_NAME"
			rm ./_tmp/substitute.sh "$OLD_NAME"
			return 0
			;;
		fail | override | append | transform | nothing)
			sh -ex ./_tmp/substitute.sh <./_tmp/substitute >"$NEW_NAME"
			rm ./_tmp/substitute ./_tmp/substitute.sh "$OLD_NAME"
			return 0
			;;
		*)
			bold "substitute: Invalid mode: $1"
			bold "substitute: Allowed modes:"
			bold "fail fail! override override! append append! transform transform? transform! nothing nothing!" | justify 50 "substitute:   "
			return 1
			;;
		esac
	fi
}

merge_dir() {
	[ "$#" -ne 2 ] && return 2
	for subchild in "$2"/*; do
		# "$2"/.*; do
		# [ "$subchild" = "$2"/.'*' ] && continue
		[ "$subchild" = "$2"/'*' ] && continue
		[ "$subchild" = "$2"/. ] && continue
		[ "$subchild" = "$2"/.. ] && continue
		BASENAME=$(basename "$subchild")
		if [ -d "$subchild" ]; then
			[ -f "$1/$BASENAME" ] && fail1 "merge_dir: Cannot override $1/$BASENAME"
			mkdir -p "$1/$BASENAME"
			merge_dir "$1/$BASENAME" "$2/$BASENAME"
		elif [ -f "$subchild" ]; then
			[ -e "$1/$BASENAME" ] && fail1 "merge_dir: Cannot override $1/$BASENAME"
			mv "$subchild" "$1/$BASENAME"
		fi
	done
	for subchild in "$2"/.*; do
		[ "$subchild" = "$2"/.'*' ] && continue
		[ "$subchild" = "$2"/. ] && continue
		[ "$subchild" = "$2"/.. ] && continue
		BASENAME=$(basename "$subchild")
		if [ -d "$subchild" ]; then
			[ -f "$1/$BASENAME" ] && fail1 "merge_dir: Cannot override $1/$BASENAME"
			mkdir -p "$1/$BASENAME"
			merge_dir "$1/$BASENAME" "$2/$BASENAME"
		elif [ -f "$subchild" ]; then
			rm "$subchild"
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

export S="$" # Used for trickery w/envsubst

check_env

mkdir -p ./_tmp

env_load ./config.env

env_require './config.env' <<EOF
CONTEST_ID CONTEST_NAME
EOF
export CONTESTID="$CONTEST_ID"
export CONTESTNAME="$CONTEST_NAME"

OLDLANG="$LANG"

cat >./_tmp/default-package-settings.env <<-EOF
	# Task ID, must be 3 lowercase ASCII letters
	ID=
	# Human readable name, as shown in the task statement
	NAME=
	# Older name of the task, to use in the released status table. Defaults to \$NAME
	OLDNAME=
	# Name of the task template to use. The available templates are:
	$(find ./_templates/* -prune -type d -exec basename {} ';' | grep -vE '^_.*$' | justify 60 '#> ')
	TEMPLATE=${DEF_TEMPLATE:-standard}
	# Name of the additional libraries to include. Available are:
	$(find ./_templates/_lib/* -prune -type d -exec basename {} ';' | justify 60 '#> ')
	LIBRARIES='${DEF_LIBRARIES:-oi testgen}'
	# Whether to include the local template. Should usually be true.
	LOCAL=${DEF_LOCAL:-true}
	# Identifier of the language to use in the document templates
	LANG=${DEF_LANG:-pl}
	# Default RAM limit, in megabytes. Can change manually later.
	MEMORY=${DEF_MEMORY:-512}
	# Default time limit, in whole seconds. Can change manually later.
	TIME=${DEF_TIME:-2}
	# Default number of subtasks to generate. Can change manually later.
	SUBTASKS=${DEF_SUBTASKS:-4}
EOF

RECOVER=
if [ -f "./_tmp/new-package-settings.env" ] && ! diff "./_tmp/new-package-settings.env" "./_tmp/default-package-settings.env" >/dev/null; then
	while [ -z "${RECOVER:-}" ]; do
		bold "An old package specification was found. Recover? (y/n)"
		read -r _recover_opt
		case "$_recover_opt" in
		[yY] | [yY][eE][sS])
			RECOVER=true
			;;
		[nN] | [nN][oO])
			RECOVER=false
			;;
		*)
			echo "Expected either y[es] or n[o]. Please try again."
			;;
		esac
	done
else
	RECOVER=false
fi

if ! "$RECOVER"; then
	mv ./_tmp/default-package-settings.env ./_tmp/new-package-settings.env
else
	rm ./_tmp/default-package-settings.env
fi

${EDITOR:-nano} "./_tmp/new-package-settings.env"
env_load <"./_tmp/new-package-settings.env"

env_require './new-package.sh' <<EOF
ID NAME TEMPLATE
EOF

export TASKLANG="${LANG:-pl}"
export LANG="$OLDLANG"
export LOCAL="${LOCAL:-true}"
export MEMORY="${MEMORY:-512}"
export MEMORY_KB=$((MEMORY * 1024))
TIME="$(printf "%.3f" "${TIME:-2}")"
TIME_MS=$(echo "$TIME" | tr -d ".")
TIME="${TIME%0}"
TIME="${TIME%0}"
TIME="${TIME%0}"
TIME="${TIME%'.'}"
export TIME
export TIME_MS
export LIBRARIES="${LIBRARIES:-}"
export SUBTASKS="${SUBTASKS:-4}"

export TASKID="$ID"
export TASKNAME="$NAME"
export OLDNAME="${OLDNAME:-}"

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
	if ! [ -d "./_templates/$1" ]; then
		case "$1" in
		_lib/*)
			fail1 "template: Unknown library: ${1#'_lib/'}"
			;;
		_local)
			bold "template: _local template doesn't exist. Skipping."
			return 0
			;;
		*)
			fail1 "template: Unknown template: $1"
			;;
		esac
	fi

	case "$APPLIED_TEMPLATES" in
	*" $1 "*)
		bold "template: Template $1 already applied"
		return 0
		;;
	*)
		bold "template: Resolving $1..."
		;;
	esac
	case "$RESOLVED_TEMPLATES" in
	*" $1 "*)
		bold "template: Failed resolution due to a dependency loop."
		return 1
		;;
	*)
		true
		;;
	esac

	RESOLVED_TEMPLATES="$RESOLVED_TEMPLATES$1 "
	if [ -f "./_templates/$1/_extend" ]; then
		bold "template: Resolving dependencies for $1..."
		while IFS= read -r extend; do
			apply_template "$(dirname "./_templates/$1")/$extend"
		done <"./_templates/$1/_extend"
	fi
	bold "template: Applying $1..."
	cp -RL "./_templates/$1" "./_tmp/_copy"
	rm -f "./_tmp/copy/_extend"
	merge_dir "./_tmp/$TASKID" "./_tmp/_copy"
	substitute "./_tmp/$TASKID"
	bold "template: Applied $1"
	APPLIED_TEMPLATES="$APPLIED_TEMPLATES$1 "
}

rm -rf "./_tmp/_copy"
rm -rf "./_tmp/$TASKID"
mkdir -p "./_tmp/$TASKID"
for template in $templates; do
	apply_template "$template"
done

mv "./_tmp/$TASKID" "./$TASKID"
[ -n "$OLDNAME" ] && echo "$OLDNAME" >"./${TASKID}/.old-name"

rm -f./_tmp/new-package-settings.env

bold "Created new task in ./$TASKID"
exit 0
