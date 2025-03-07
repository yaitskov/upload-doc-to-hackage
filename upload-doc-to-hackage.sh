#!/usr/bin/env bash

set -e

HACKAGE_USER=${HACKAGE_USER:-DaniilIaitskov}
HACKAGE_PASS=${HACKAGE_PASS:-~/.hackage-pass}
DRY_RUN=

function die() {
    echo "$@" 1>&2
    exit 1
}

if [ -f "$HACKAGE_PASS" ] ; then
    HACKAGE_PASS="$(cat $HACKAGE_PASS)"
else
    unset HACKAGE_PASS
fi


while [ $# -ne 0 ] ; do
    case "$1" in
        -h|--help) cat<<EOF
Usage: hackage-upload.sh [ options ]

The script uploads cabal package docs to hackage.
Run the script in the root project folder with cabal file.
If doc archive is missing or older than current project version
then doc archive is generated.

User and Password can be set via HACKAGE_USER and HACKAGE_PASS
environment variables correspondently.
HACKAGE_PASS default is ~/.hackage-pass

Options:
  -u <user>
  -p <password-file>
  -v                   verbose
  -d                   dry run
EOF
                   exit 1;;
        -v) set -x ;;
        -u) shift;
            if [ -n "$1" ] ; then
                HACKAGE_USER="$1"
            else
                die "-u expects argument"
            fi;;
        -p) shift;
            if [ -f "$1" ] ; then
                HACKAGE_PASS="$(cat $1)"
            else
                die "Password file [$1] is not found"
            fi;;
        -d) DRY_RUN=1;;
        *) die "Bad argument [$1]. See help.";;
    esac
    shift
done

[ -z "$HACKAGE_PASS" ] && die "No password is provided."

case $(ls -1 *.cabal | wc -l) in
    0) die "Folder $PWD does not have a cabal file." ;;
    1) CABAL_FILE="$(ls -1 *.cabal)"
       PACKAGE_NAME=${CABAL_FILE%*.cabal} ;;
    *) die "Folder $PWD contains multiple cabal files." ;;
esac

VERSION_LINE="$(grep -oE '^version:[[:space:]]*[0-9.]+$' $CABAL_FILE)"
if [[ "$VERSION_LINE" =~ ^version:[[:space:]]*([0-9.]+)$ ]] ; then
    PACKAGE_VERSION=${BASH_REMATCH[1]}
else
    die "$CABAL_FILE does not have version."
fi

PACK_NV=$PACKAGE_NAME-$PACKAGE_VERSION
DOC_AR=dist-newstyle/$PACK_NV-docs.tar.gz

[ -f $DOC_AR ] || \
    cabal v2-haddock  --haddock-for-hackage --enable-doc

if [ -n "$DRY_RUN" ] ; then
    echo curl -X PUT --user "$HACKAGE_USER:$HACKAGE_PASS" \
         -H "Content-Type: application/x-tar" \
         -H 'Content-Encoding: gzip' \
         --data-binary "@"$DOC_AR \
         https://hackage.haskell.org/package/$PACK_NV/docs
   else
       curl -X PUT --user "$HACKAGE_USER:$HACKAGE_PASS" \
            -H "Content-Type: application/x-tar" \
            -H 'Content-Encoding: gzip' \
            --data-binary "@"$DOC_AR \
            https://hackage.haskell.org/package/$PACK_NV/docs
fi

echo Docs have been uploaded.
