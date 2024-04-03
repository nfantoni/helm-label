#!/bin/bash

usage() {
    cat << EOF
Description:
  This plugin retrieves the labels associated with the Helm release.

Usage: helm label [command] <release-name>

Available Commands:
  list    return the list of lables associated at the release in json format

Params:
  <release-name>    Name of the Helm release

Flags:
  -h, --help  help for the helm plugin

EOF
}

list(){
    RELEASE_NAME=$1
    # Get the revision information with helm list
    HELM_LIST=$(helm list --filter $RELEASE_NAME -o yaml)
    if [ $? -ne 0 ]; then
        echo "Error running helm list command"
        exit 1
    fi

    # Get the revision number from the yaml output
    REVISION=$(echo "$HELM_LIST" | awk '/revision:/ {print $2}' | sed 's/"//g')
    if [ -z "$REVISION" ]; then
        echo "Revision not found for release: $RELEASE_NAME"
        exit 1
    fi

    # Exec kubectl on secret associated to retrive the label information
    kubectl get secret -l "owner=helm,name=$RELEASE_NAME,version=$REVISION" -o=jsonpath='{.items[*].metadata.labels}'

    if [ $? -ne 0 ]; then
        echo "Error running kubectl command"
        exit 1
    fi
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

# Check if the argument list is correct
if [ $# -ne 2 ]; then
    echo "Error: Missing argument."
    usage
    exit 1
fi

ACTION=$1

# Verifica se $1 è "list"
if [ "$1" = "list" ]; then
    if [ $# -ne 2 ]; then
        echo "Error: Missing argument for list command."
        usage
        exit 1
    fi
    list "$2"
    exit 0
fi


