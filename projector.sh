#!/bin/env bash

DOC="projector: manages work directories synchronized with distant storage.

Usage:
    projector (--help|-h)
    projector init NAME REMOTE_PATH
    projector pull NAME
    projector push NAME
    projector drop NAME

Options:
    --help  Prints this help.
    -h      Prints Usage.

Commands:
    init    Initializes a local project NAME with remote copy REMOTE_PATH.
    pull    Synchronizes the local project NAME with remote copy.
    push    Synchronizes the remote copy with local project NAME.
    drop    Destroys local copy of project NAME.

Parameters:
    NAME        The name of the project.
    REMOTE_PATH The path of remote copy in the form of rsync paths.

Description:
    projector looks in '\$XDG_CONFIG_HOME/projector/projectorrc' for the local
    projects' path. By default it is '\$HOME/Projects/'. When a new	local
    project is initialized, a directory is created in '\$PROJECT_PATH/\$NAME'.
    When it is synced, the command 'rsync' is used with parameters
    '\$PROJECT_PATH/\$NAME' and '\$REMOTE_PATH'. When it is dropped, the
    directory '\$PROJECT_PATH/\$NAME' is recursively deleted."

DOC_LIGHT="Usage:
    projector (--help|-h)
    projector init NAME REMOTE_PATH
    projector pull NAME
    projector push NAME
    projector drop NAME"

die () {
    if [ $# -ne 1 ]
    then
        1>&2 echo "Bad use of 'die' function."
        exit 2
    fi
    1>&2 echo "$1"
    1>&2 echo "$DOC_LIGHT"
    exit 1
}

if [ $# -ne 1 ] && [ $# -ne 2 ] && [ $# -ne 3 ]
then
    die "Bad number of argument."
fi

case "$1" in
    "--help")
        echo "$DOC"
        ;;
    "-h")
        echo "$DOC_LIGHT"
        ;;
    "init") [ $# -ne 3 ] && die "Command 'init' takes 2 arguments."
        NAME="$2"; REMOTE_PATH="$3"
        PROJECT_PATH="$HOME/Projects/$NAME"
        [ -e "$PROJECT_PATH" ] && die "'$PROJECT_PATH' already exists."
        mkdir -p "$PROJECT_PATH/work"
        echo "$REMOTE_PATH" > "$PROJECT_PATH/.projector"
        ;;
    "pull") [ $# -ne 2 ] && die "Command 'pull' takes 1 arguments."
        NAME="$2"
        PROJECT_PATH="$HOME/Projects/$NAME"
        [ -d "$PROJECT_PATH" ] && [ -d "$PROJECT_PATH/work" ] && [ -f "$PROJECT_PATH/.projector" ] || die "'$PROJECT_PATH' is not a projector project."
        REMOTE_PATH=$(cat "$PROJECT_PATH/.projector")
        [ -z "$REMOTE_PATH" ] && die "Remote path is empty."
        rsync -a --delete "$REMOTE_PATH" "$PROJECT_PATH/work/"
        ;;
    "push") [ $# -ne 2 ] && die "Command 'push' takes 1 arguments."
        NAME="$2"
        PROJECT_PATH="$HOME/Projects/$NAME"
        [ -d "$PROJECT_PATH" ] && [ -d "$PROJECT_PATH/work" ] && [ -f "$PROJECT_PATH/.projector" ] || die "'$PROJECT_PATH' is not a projector project."
        REMOTE_PATH=$(cat "$PROJECT_PATH/.projector")
        [ -z "$REMOTE_PATH" ] && die "Remote path is empty."
        rsync -a --delete "$PROJECT_PATH/work/" "$REMOTE_PATH"
        ;;
    "drop") [ $# -ne 2 ] && die "Command 'drop' takes 1 arguments."
        NAME="$2"
        PROJECT_PATH="$HOME/Projects/$NAME"
        [ -d "$PROJECT_PATH" ] && [ -d "$PROJECT_PATH/work" ] && [ -f "$PROJECT_PATH/.projector" ] || die "'$PROJECT_PATH' is not a projector project."
        rm -r "$PROJECT_PATH"
        ;;
    *)  die "Unknown command '$1'." ;;
esac
