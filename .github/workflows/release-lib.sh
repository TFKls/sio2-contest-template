# THIS MUST BE SOURCED
# shellcheck shell=bash
load_release() {
	rm -rf ./_build/
	mkdir ./_build/
	mkdir ./_build/results
	touch ./_build/status
	cat >./_build/base-release-notes.md <<EOF
Task packages and statements, generated on push by a github action.
Last update: 0000-00-00 00:00:00 +0000 (commit 00000000) <!-- DO NOT EDIT THIS LINE -->

Current task status:
\`\`\`
❌ - To be done            # add !todo   to commit title to alter task's state, or edit by hand
⌛ - Done, to be verified  # add !done   to commit title to alter task's state, or edit by hand
✅ - Done and verified     # add !verify to commit title to alter task's state, or edit by hand
\`\`\`

<!-- BEGIN_STATUS_TABLE -->
| Id | State | Name | Old name | Files | Build info |
|----|-------|------|----------|-------|------------|
<!-- END_STATUS_TABLE -->
EOF

	if ! gh release view tasks >/dev/null; then
		gh release create tasks --title 'Tasks' --notes-file ./_build/base-release-notes.md
	fi

	gh release view tasks --json body --jq '.body' >./_build/release-notes.md
	grep '^Last update:' ./_build/release-notes.md | cut -c 14-38 >./_build/release-time
	grep '^Last update:' ./_build/release-notes.md | sed -Ee 's/.*?\(commit ([0-9a-f]+)\)/\1/' | tr -cd '0-9a-f\n' >./_build/release-commit
	RELEASE_TIME=$(cat ./_build/release-time)
	RELEASE_COMMIT=$(cat ./_build/release-commit)

	if [ "$RELEASE_TIME" = "0000-00-00 00:00:00 +0000" ]; then
		git fetch --unshallow
	else
		git fetch --shallow-since "$RELEASE_TIME"
	fi

	if [ "$RELEASE_TIME" = "0000-00-00 00:00:00 +0000" ]; then
		git log --pretty=format:%s | tee ./_build/git-logs
	else
		git log "$RELEASE_COMMIT..HEAD" --pretty=format:%s | tee ./_build/git-logs
	fi

	sed -ne '/BEGIN_STATUS_TABLE/,/END_STATUS_TABLE/p' ./_build/release-notes.md | head -n -1 | tail -n +4 >./_build/release-notes.table

	rm -f ./_build/update
	if ! [ -f './.forced-rebuild' ]; then
		touch ./_build/git-logs-rebuild
		grep -ohEi '!rebuild-(([a-z][a-z][a-z])|\*)' ./_build/git-logs >>./_build/git-logs-rebuild || true
		grep -ohEi '(([a-z][a-z][a-z])|\*): .*!rebuild([^-]|$)' ./_build/git-logs >>./_build/git-logs-rebuild || true
		while IFS= read -r word; do
			case "$word" in
			'*: '* | '!rebuild-*')
				gh release edit tasks --notes-file ./_build/base-release-notes.md
				touch './.forced-rebuild'
				load_release && exit "$?" || exit "$?"
				;;
			[a-z][a-z][a-z]': '* | '!rebuild-'[a-z][a-z][a-z])
				dir=$(echo "${word#"!rebuild-"}" | head -c 3)
				grep -q "^${dir}$" ./_build/update 2>/dev/null && continue
				[ -d "$dir" ] && echo "$dir" >>./_build/update
				;;
			*)
				# Unreachable, but we don't care
				true
				;;
			esac
		done <./_build/git-logs-rebuild
	fi

	for dir in [a-z][a-z][a-z]; do
		[ "$dir" = '[a-z][a-z][a-z]' ] && continue
		grep "^${dir}: " ./_build/git-logs >./_build/git-logs-"${dir}" || touch ./_build/git-logs-"${dir}"
		grep -q "^${dir}$" ./_build/update 2>/dev/null && continue
		if [ "$RELEASE_COMMIT" = "00000000" ]; then
			echo "$dir" >>./_build/update
		elif [ "$RELEASE_COMMIT" = "$(git rev-parse --short HEAD)" ]; then
			true
		elif grep "^| ${dir} |" ./_build/release-notes.table; then
			git diff --quiet "$RELEASE_COMMIT" HEAD ./"$dir" || echo "$dir" >>./_build/update
		else
			echo "$dir" >>./_build/update
		fi
	done

	[ -f "./_build/update" ] && echo "update=true" >>"$GITHUB_OUTPUT" || echo "update=false" >>"$GITHUB_OUTPUT"
	touch ./_build/update
}

save_release() {
	mv ./_build/release-notes.md ./_build/old-release-notes.md
	cat >./_build/release-notes.md <<EOF
Task packages and statements, generated on push by a github action.
Last update: $(git log HEAD^..HEAD --pretty=format:%ai) (commit $(git rev-parse --short HEAD)) <!-- DO NOT EDIT THIS LINE -->

Current task status:
\`\`\`
❌ - To be done            # add !todo   to commit title to alter task's state, or edit by hand
⌛ - Done, to be verified  # add !done   to commit title to alter task's state, or edit by hand
✅ - Done and verified     # add !verify to commit title to alter task's state, or edit by hand
\`\`\`
<!-- BEGIN_STATUS_TABLE -->
| Id | State | Name | Old name | Files | Build info |
|----|-------|------|----------|-------|------------|
EOF
	RELEASE_TIME=$(cat ./_build/release-time)
	RELEASE_COMMIT=$(cat ./_build/release-commit)
	gh release view tasks --json assets --jq '.assets | map(.name) | .[]' >./_build/old-assets
	for dir in $(echo [a-z][a-z][a-z] | sort); do
		[ "$dir" = '[a-z][a-z][a-z]' ] && continue
		if line=$(grep "^| ${dir} |" ./_build/release-notes.table); then
			STATE=$(echo "$line" | head -n 1 | cut -d '|' -f 3 | xargs)
			NAME=$(echo "$line" | head -n 1 | cut -d '|' -f 4 | xargs)
			OLDNAME=$(echo "$line" | head -n 1 | cut -d '|' -f 5 | xargs)
			BUILD=$(echo "$line" | head -n 1 | cut -d '|' -f 6 | xargs)
			STATUS=$(echo "$line" | head -n 1 | cut -d '|' -f 7 | xargs)
		else
			STATE="❌"
			NAME=$(grep -E "^title:" "${dir}/config.yml" | head -n 1 | sed -e 's/^title://' -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//" -e 's/|/&vert;/g')
			[ -z "$NAME" ] && NAME="Unknown"
			[ -f "./${dir}/.old-name" ] && OLDNAME="$(sed -e 's/|/&vert;/g' "./${dir}/.old-name")" || OLDNAME="$NAME"
			BUILD="Unknown"
			STATUS="Last build: Unknown (never built)"
		fi
		if grep -q "^${dir}\$" "./_build/update"; then
			STATUS=$(grep "^${dir}:" ./_build/status | tail -c +5)
			STATUS="Last build: $STATUS (commit $(git rev-parse --short HEAD))<br>Warnings:"

			! [ -f "./${dir}/doc/Makefile" ] || grep -q "actions:.*not-interactive" "./${dir}/doc/Makefile" || STATUS="$STATUS<br>\`\`\`doc/Makefile may be interactive and cause timeouts. Add -halt-on-error to pdftex options and the following comment to the Makefile to silence this warning: # actions: not-interactive\`\`\`"

			BUILD="[Build&nbsp;logs](https://github.com/$GH_REPO/releases/download/tasks/${dir}.log)"
			gh release upload tasks "./_build/results/${dir}.log" --clobber

			if [ -f "./_build/results/${dir}.pdf" ]; then
				BUILD="$BUILD<br>[Statement](https://github.com/$GH_REPO/releases/download/tasks/${dir}.pdf)"
				gh release upload tasks "./_build/results/${dir}.pdf" --clobber
			else
				grep -q "^${dir}.pdf$" ./_build/old-assets && gh release delete-asset tasks "${dir}.pdf"
				STATUS="$STATUS<br>\`No statement file generated.\`"
			fi
			if [ -f "./_build/results/${dir}.tgz" ]; then
				BUILD="$BUILD<br>[Package](https://github.com/$GH_REPO/releases/download/tasks/${dir}.tgz)"
				gh release upload tasks "./_build/results/${dir}.tgz" --clobber
			else
				grep -q "^${dir}.tgz$" ./_build/old-assets && gh release delete-asset tasks "${dir}.tgz"
				STATUS="$STATUS<br>\`No package file generated.\`"
			fi
		fi

		# shellcheck disable=SC2013
		while IFS= read -r line; do
			case "$line" in
			*'!ver'*)
				STATE="✅"
				break
				;;
			*'!done'*)
				STATE="⌛"
				break
				;;
			*'!todo'*)
				STATE="❌"
				break
				;;
			*)
				true
				;;
			esac
		done <"./_build/git-logs-${dir}"
		echo "| ${dir} | ${STATE} | ${NAME} | ${OLDNAME} | ${BUILD} | ${STATUS} |" >>./_build/release-notes.md
	done
	echo '<!-- END_STATUS_TABLE -->' >>./_build/release-notes.md

	gh release edit tasks --latest --notes-file ./_build/release-notes.md
}
