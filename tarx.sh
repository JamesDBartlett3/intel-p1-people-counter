#!/bin/bash

# Tar and compress files using tqdm or pv for a progress bar.

# * Safety

# NOTE: These are disabled by default in this template but should be
# enabled when feasible.  Documentation is from the Bash man page.

# ** errexit

# Exit immediately if a pipeline (which may consist of a single simple
# command), a list, or a compound command (see SHELL GRAMMAR above),
# exits with a non-zero status.  The shell does not exit if the
# command that fails is part of the command list immediately following
# a while or until keyword, part of the test following the if or elif
# reserved words, part of any command executed in a && or || list
# except the command follow‐ ing the final && or ||, any command in a
# pipeline but the last, or if the command's return value is being
# inverted with !.  If a compound command other than a subshell
# returns a non-zero status because a command failed while -e was
# being ignored, the shell does not exit.  A trap on ERR, if set, is
# executed before the shell exits.  This option applies to the shell
# environment and each subshell environment separately (see COMMAND
# EXECUTION ENVIRONMENT above), and may cause subshells to exit before
# executing all the commands in the subshell.

# If a compound command or shell function executes in a context where
# -e is being ignored, none of the commands executed within the
# compound command or function body will be affected by the -e
# setting, even if -e is set and a command returns a failure status.
# If a compound command or shell function sets -e while executing in a
# context where -e is ignored, that setting will not have any effect
# until the compound command or the command containing the function
# call completes.

set -o errexit

# ** pipefail

# If set, the return value of a pipeline is the value of the last
# (rightmost) command to exit with a non-zero status, or zero if all
# commands in the pipeline exit successfully.  This option is disabled
# by default.

set -o pipefail

# * Defaults

with=bzip2
progress=tqdm

# * Functions

function debug {
    if [[ $debug ]]
    then
        function debug {
            echo "DEBUG: $@" >&2
        }
        debug "$@"
    else
        function debug {
            true
        }
    fi
}
function error {
    echo "ERROR: $@" >&2
    ((errors++))  # Initializes automatically
}
function die {
    error "$@"
    exit $errors
}
function usage {
    cat <<EOF
$0 [OPTIONS] PATH...

Archive and compress PATHs with tar and archiver, reporting progress with pv or tqdm.

Options
  -d, --debug  Print debug info
  -h, --help   I need somebody!

  --compare           After writing FILE, compare archive contents with filesystem
  -t, --to FILE       Compress to archive FILE instead of STDOUT
  -w, --with COMMAND  Compress with archiver COMMAND (e.g. bzip2, the default)

  -p, --progress pv|tqdm  Use pv or tqdm (the default) as progress reporter
EOF
}

function command_exists {
    type $1 &>/dev/null
}

# ** Progress reporters

function tqdm {
    command tqdm --bytes --unit B --unit_scale --total $total_size
}
function pv {
    command pv --progress --timer --eta --rate --average-rate --bytes --size $total_size
}

# * Args

args=$(getopt -n "$0" -o dhp:t:w: -l compare,debug,help,progress:,to:,with: -- "$@") || { usage; exit 1; }
eval set -- "$args"

while true
do
    case "$1" in
        -d|--debug)
            debug=true
            ;;
        -h|--help)
            usage
            exit
            ;;
        --compare)
            compare=true
            ;;
        -p|--progress)
            shift
            progress="$1"
            ;;
        -t|--to)
            shift
            to="$1"
            ;;
        -w|--with)
            shift
            with="$1"
            ;;
        --)
            # Remaining args (required; do not remove)
            shift
            paths=("$@")
            break
            ;;
    esac

    shift
done

debug "ARGS: $args"
debug "Paths: ${paths[@]}"

# * Main

# ** Verify args

# MAYBE: Get archiver from archive filename extension when compressing to file.

# Destination file
[[ $to ]] && [[ -e $to ]] && die "Destination already exists: $to"

# Archiver command
if [[ $with =~ ^([^[:space:]]+)[[:space:]] ]]
then
    # Has arguments: use command name
    command_exists ${BASH_REMATCH[1]} || die "Archiver command not found: ${BASH_REMATCH[1]}"
else
    command_exists $with || die "Archiver command not found: $with"
fi

# Progress command
if ! command_exists $progress
then
    # Try pv instead
    old_progress=$progress
    progress=pv
    if ! command_exists $progress
    then
        die "$old_progress not found, and $progress also not found"
    else
        error "$old_progress not found: using pv instead"
    fi
fi

# ** Get disk space

total_size=$(du -bc "${paths[@]}" | tail -n1 | cut -f1) || die "Couldn't determine total size"
debug "Total size: $total_size"

# ** Run command

if [[ $to ]]
then
    tar --create "${paths[@]}" | $progress | $with >"$to"
    tar_exit=$?

    if [[ $tar_exit = 0 ]] && [[ $compare ]]
    then
        tar --compare --file "$to"
    else
        exit $tar_exit
    fi
else
    tar --create "${paths[@]}" | $progress | $with
fi
