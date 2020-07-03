#!/bin/sh
version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

gem install -N rubocop $(version $INPUT_RUBOCOP_VERSION)

echo $INPUT_RUBOCOP_EXTENSIONS | xargs gem install -N

git diff origin/develop --name-only --diff-filter=AM \
  | { egrep -i "\.rb|\.rake$"; echo Gemfile } \
  | xargs rubocop ${INPUT_RUBOCOP_FLAGS} \
  | reviewdog -f=rubocop \
      -name="${INPUT_TOOL_NAME}" \
      -reporter="${INPUT_REPORTER}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}
