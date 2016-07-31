assert_ok() {
  [ -n "${KSH_VERSION-}" ] || local FUNCTION
  FUNCTION=$1
  shift

  $($FUNCTION $@) || die '"'"$FUNCTION $@"'" should have succeeded, but failed'
}

assert_not_ok() {
  [ -n "${KSH_VERSION-}" ] || local FUNCTION
  FUNCTION=$1
  shift

  ! $($FUNCTION $@) || die '"'"$FUNCTION $@"'" should have failed, but succeeded'
}

strip_colors() {
  while read -r line; do
    echo "$line" | LC_ALL=C command sed 's/\[[ -?]*[@-~]//g'
  done
}

make_echo() {
  echo "#!/bin/sh" > "$1"
  echo "echo \"${2}\"" > "$1"
  chmod a+x "$1"
}

make_fake_node() {
  [ -n "${KSH_VERSION-}" ] || local VERSION
  VERSION="${1-}"
  [ -n "${VERSION}" ] || return 1

  [ -n "${KSH_VERSION-}" ] || local BIN_PATH
  BIN_PATH="$(nvm_version_path "${VERSION}")/bin"
  mkdir -p "${BIN_PATH}" || {
    echo >&2 'unable to make bin dir'
    return 2
  }

  make_echo "${BIN_PATH}/node" "${VERSION}" || {
    echo >&2 'unable to make fake node bin'
    return 3
  }
}

make_fake_iojs() {
  [ -n "${KSH_VERSION-}" ] || local VERSION
  VERSION="${1-}"
  [ -n "${VERSION}" ] || return 1

  [ -n "${KSH_VERSION-}" ] || local BIN_PATH
  BIN_PATH="$(nvm_version_path "iojs-${VERSION}")/bin"
  mkdir -p "${BIN_PATH}" || {
    echo >&2 'unable to make bin dir'
    return 2
  }

  make_echo "${BIN_PATH}/node" "${VERSION}" || {
    echo >&2 'unable to make fake node bin'
    return 3
  }
  make_echo "${BIN_PATH}/iojs" "${VERSION}" || {
    echo >&2 'unable to make fake iojs bin'
    return 3
  }
}

watch() {
  $@ &
  [ -n "${KSH_VERSION-}" ] || local JOB
  JOB=$!
  while true; do sleep 15; >&2 echo '* ping *'; done &
  wait $JOB;
  [ -n "${KSH_VERSION-}" ] || local EXIT_CODE
  EXIT_CODE=$?
  kill %2;
  return $EXIT_CODE
}
