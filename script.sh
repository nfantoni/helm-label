#!/bin/bash

usage() {
    cat << EOF
Usage: helm label <release-name>

Options:
  <release-name>  Name of the Helm release

Description:
  This script retrieves the labels associated with the Helm release.

EOF
}

if [ $# -ne 1 ]; then
    usage
    exit 0
fi

RELEASE_NAME=$1

# Esegui helm list per ottenere le informazioni sulla release
HELM_LIST=$(helm list --filter $RELEASE_NAME -o yaml)
if [ $? -ne 0 ]; then
    echo "Error running helm list command"
    exit 1
fi

# Analizza l'output YAML per ottenere il numero di revisione
REVISION=$(echo "$HELM_LIST" | awk '/revision:/ {print $2}' | sed 's/"//g')
if [ -z "$REVISION" ]; then
    echo "Revision not found for release: $RELEASE_NAME"
    exit 1
fi

# Esegui kubectl per ottenere le informazioni sul secret
LABEL=$(kubectl get secret -l "owner=helm,name=$RELEASE_NAME,version=$REVISION" -o=jsonpath='{.items[*].metadata.labels}')

LABEL=${LABEL#"{"}
LABEL=${LABEL%"}"}

array=()

IFS=',' read -r -a array <<< "$LABEL"

# Stampa l'array
for elemento in "${array[@]}"; do
    echo "$elemento" | tr -d '"' | tr ':' '='
done

if [ $? -ne 0 ]; then
    echo "Error running kubectl command"
    exit 1
fi
