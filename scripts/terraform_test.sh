#!/bin/bash

tf_files=$1

if [ -z $tf_files ]; then
    echo "===> Required arg. Usage: $0 <directory or terraform files>"
    exit 1
fi

bash <(curl -Ss https://bitbucket.org/footcoin/build-harness/raw/master/bin/terraform_test.sh) "$tf_files"

exit
