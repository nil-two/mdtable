#!/usr/bin/env bats

readonly mdtable=$BATS_TEST_DIRNAME/../mdtable
readonly tmpdir=$BATS_TEST_DIRNAME/../tmp
readonly stdout=$BATS_TEST_DIRNAME/../tmp/stdout
readonly stderr=$BATS_TEST_DIRNAME/../tmp/stderr
readonly exitcode=$BATS_TEST_DIRNAME/../tmp/exitcode

setup() {
  if [[ $BATS_TEST_NUMBER == 1 ]]; then
    mkdir -p -- "$tmpdir"
  fi
}

teardown() {
  if [[ ${#BATS_TEST_NAMES[@]} == $BATS_TEST_NUMBER ]]; then
    rm -rf -- "$tmpdir"
  fi
}

check() {
  printf "%s\n" "" > "$stdout"
  printf "%s\n" "" > "$stderr"
  printf "%s\n" "0" > "$exitcode"
  "$@" > "$stdout" 2> "$stderr" || printf "%s\n" "$?" > "$exitcode"
}

@test 'mdtable: print usage if "--help" passed' {
  check "$mdtable" --help
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") =~ ^usage ]]
}

@test 'mdtable: print error if unknown option passed' {
  check "$mdtable" --test
  [[ $(cat "$exitcode") == 1 ]]
  [[ $(cat "$stderr") =~ ^'mdtable: unrecognized option' ]]
}

@test 'mdtable: convert TSV to Markdown table' {
  src=$(printf "%s\n" $'
  header1\theader2
  1\t3
  2\t4
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  | header1 | header2 |
  |---------|---------|
  | 1       | 3       |
  | 2       | 4       |
  ' | sed -e '1d' -e 's/^  //')

  check "$mdtable" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'mdtable: allow empty field' {
  src=$(printf "%s\n" $'
  header1\theader2\theader3
  \t\t
  10\t\t
  \t10\t
  \t\t10
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  | header1 | header2 | header3 |
  |---------|---------|---------|
  |         |         |         |
  | 10      |         |         |
  |         | 10      |         |
  |         |         | 10      |
  ' | sed -e '1d' -e 's/^  //')

  check "$mdtable" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'mdtable: allow space in fields' {
  src=$(printf "%s\n" $'
  header1\theader2
  10 20 30\t40  
    50\t  60
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  | header1  | header2 |
  |----------|---------|
  | 10 20 30 | 40      |
  |   50     |   60    |
  ' | sed -e '1d' -e 's/^  //')

  check "$mdtable" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'mdtable: supports multi width charactors' {
  src=$(printf "%s\n" $'
  日本語\t記号
  加速\t！？
  旋回\t【「『』」】
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  | 日本語 | 記号         |
  |--------|--------------|
  | 加速   | ！？         |
  | 旋回   | 【「『』」】 |
  ' | sed -e '1d' -e 's/^  //')

  check "$mdtable" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'mdtable: convert Markdown table to TSV when "-d" passed' {
  src=$(printf "%s\n" $'
  | header1 | header2 |
  |---------|---------|
  | 1       | 3       |
  | 2       | 4       |
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  header1\theader2
  1\t3
  2\t4
  ' | sed -e '1d' -e 's/^  //')

  check "$mdtable" -d <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'mdtable: convert Markdown table to TSV when "--deconvert" passed' {
  src=$(printf "%s\n" $'
  | header1 | header2 |
  |---------|---------|
  | 1       | 3       |
  | 2       | 4       |
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  header1\theader2
  1\t3
  2\t4
  ' | sed -e '1d' -e 's/^  //')

  check "$mdtable" --deconvert <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'mdtable: can reconvert' {
  src=$(printf "%s\n" $'
  | header1 | header2 |
  |---------|---------|
  | 1       | 3       |
  | 2       | 4       |
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  | header1 | header2 |
  |---------|---------|
  | 1       | 3       |
  | 2       | 4       |
  ' | sed -e '1d' -e 's/^  //')

  check env mdtable=$mdtable bash -c '"$mdtable" -d | "$mdtable"' <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

# vim: ft=sh
