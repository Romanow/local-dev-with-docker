#!/usr/bin/env bash

shopt -s extglob

RED='\033[0;31m'
NOCOLOR='\033[0m'

timed() {
  end=$(date +%s)
  dt=$(("$end" - $1))
  dd=$(("$dt" / 86400))
  dt2=$(("$dt" - 86400 * "$dd"))
  dh=$(("$dt2" / 3600))
  dt3=$(("$dt2" - 3600 * "$dh"))
  dm=$(("$dt3" / 60))
  ds=$(("$dt3" - 60 * "$dm"))

  LC_NUMERIC=C printf "\nTotal runtime: %02d min %02d seconds\n" "$dm" "$ds"
}

start=$(date +%s)
trap 'timed $start' EXIT

declare -A process
services="$*"

{
  trap 'kill 0' SIGINT
  for dir in ./modules/*; do
    name="$(basename "$dir")"

    if [[ "${services}" && ! "${services[*]}" =~ ${name} ]]; then
      printf "=== Skipping building module %s ===\n" "$name"
      continue
    fi

    gradle="$dir"/gradlew
    maven="$dir"/mvnw
    npm="$dir"/package.json
    project_type="unknown"
    [[ -f "$gradle" ]] && project_type="gradle"
    [[ -f "$maven" ]] && project_type="maven"
    [[ -f "$npm" ]] && project_type="npm"

    case "$project_type" in
    gradle)
      "$gradle" clean build -p "$dir" >logs/"$name".log 2>&1 &
      ;;
    maven)
      "$maven" clean package -p "$dir" >logs/"$name".log 2>&1 &
      pid=$!
      printf "=== Building Gradle module '%s' with PID %d ===\n" "$name" "$pid"
      process[$name]=$pid
      ;;
    npm)
      (cd "$dir" && npm install && npm run build) >logs/"$name".log 2>&1 &
      ;;
    *)
      printf "=== No build configuration found for module '%s', skipping ===\n" "$name"
      ;;
    esac

    pid=$!
    printf "=== Building module '%s' with PID %d ===\n" "$name" "$pid"
    process[$name]=$pid
  done
}

for name in "${!process[@]}"; do
  pid="${process[$name]}"
  wait $pid
  code=$?

  if [[ $code -ne 0 ]]; then
    printf "${RED}Process [%s] with PID %d exit with code %d${NOCOLOR}\n" "$name" "$pid" "$code"
    exit 1
  else
    printf "Process [%s] with PID %d successfully completed\n" "$name" "$pid"
  fi
done
