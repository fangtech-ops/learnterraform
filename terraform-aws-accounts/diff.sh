#!/bin/bash

# Set your favorite diff command here:
DIFF="/usr/bin/diff --width=130 --side-by-side --suppress-common-lines"

MSG_PREFIX="FINDING:"

print_usage() {
   cat <<EOF
    This script detects differences between 2 sets of terraform source code -- for 2 AWS accounts, respectively.
    A perfect match (i.e., no difference) will result in no output messages from this script (No News is Good News).

    Use the pair of accounts 'qa71' and 'prod71' as an example. We want the differences to be
    within each account's variables.tf files only, rather than in the mainline (e.g., 'eks.tf') of the source code.
    Even for variables.tf which are supposed to have different content between 'qa71' and 'prod71',
    we want the difference to be only the value of variables, not the count and names of variables.

    Usage:
        $0 ACCT1_NAME ACCT2_NAME
    Usage Example:
        $0 qa71 prod71

    Some examples of valid arg values are (should match subdirectory names):
        - dev71
        - qa71
        - st71
        - prod71
        - devops
        - ...

    Tip 1: Each finding (printed to stdout) is prefixed with '$MSG_PREFIX'.
           To output only a summary of findings (without line-by-line details), do:
                $0 ACCT1_NAME ACCT2_NAME | grep '^$MSG_PREFIX'

    Tip 2: To change the output format (e.g., line width), customize the DIFF variable in this script.

EOF
}

print_finding() {
    echo
    echo "${MSG_PREFIX} $1"
    echo
}

raise_error() {
    echo      >&2
    echo "$1" >&2  # prints to stderr
    echo      >&2

    # If this function (or its caller) is called in a subshell syntax (e.g., $(print_terraform_src_dir ${ACCT1_NAME})),
    # then this 'exit' only exits the subshell but not the entire script.
    # That's why we have another function check_terraform_src_dir() which is called directly from main shell. It gives
    # an opportunity for this raise_error() to exit the entire script.
    exit 1
}

detect_devops_account() {
    if [[ "${ACCT1_NAME}" == "devops" || "${ACCT2_NAME}" == "devops" ]]; then
        HAS_DEVOPS_ACCOUNT="yes" # Any non-empty string will do.
    fi
}

detect_qa71_account() {
    if [[ "${ACCT1_NAME}" == "qa71" || "${ACCT2_NAME}" == "qa71" ]]; then
        HAS_QA71_ACCOUNT="yes" # Any non-empty string will do.
    fi
}

check_terraform_src_dir() {
    # The purpose of this function is to give raise_error() an opportunity to exit the entire script.
    # If the input parameter is valid, then everything here executes without problems; otherwise,
    # raise_error() will be eventually called and exits the entire script.

    ACCT_NAME=$1

    print_terraform_src_dir ${ACCT_NAME}  > /dev/null
}

print_terraform_src_dir() {
    # Returns the root dir for per-account terraform source files.

    ACCT_NAME=$1

    if   [[ ${ACCT_NAME} =~ ^devops.* ]]; then echo "./admin/${ACCT_NAME}"
    elif [[ ${ACCT_NAME} =~ ^lab.*    ]]; then echo "./lab/${ACCT_NAME}"
    elif [[ ${ACCT_NAME} =~ ^dev.*    ]]; then echo "./dev/${ACCT_NAME}"
    elif [[ ${ACCT_NAME} =~ ^qa.*     ]]; then echo "./qa/${ACCT_NAME}"
    elif [[ ${ACCT_NAME} =~ ^st.*     ]]; then echo "./st/${ACCT_NAME}"
    elif [[ ${ACCT_NAME} =~ ^prod.*   ]]; then echo "./prod/${ACCT_NAME}"
    elif [[ ${ACCT_NAME} =~ ^networking.* ]]; then
        raise_error "print_terraform_src_dir(): The 'networking' account is too different from other accounts for comparison."
    else
        raise_error "print_terraform_src_dir(): Invalid account name: '${ACCT_NAME}'"
    fi
}

print_file_relative_paths() {
    DIR=$1

    if [[ -n "$HAS_DEVOPS_ACCOUNT" ]]; then
        # The central 'devops' account's dir '40-eks1-bootstrap' is quite different
        # from any other accounts (for file names and file contents).
        # So, ignore some legit differences.
        GREP_DEVOPS_CONFIGMAP_TPL="grep -v 40-eks1-bootstrap/files/templates/configmap.tpl"
        GREP_ARGOCD="grep -v 40-eks1-bootstrap/05-secrets-manager-for-argocd.tf"
    else
        # But between other accounts (e.g., dev71 vs. prod71), it's still worth comparing.
        GREP_DEVOPS_CONFIGMAP_TPL="cat"
        GREP_ARGOCD="cat"
    fi

    if [[ -n "$HAS_QA71_ACCOUNT" ]]; then
        # 'qa71' is in the old QA account. So, it has some legit differences from
        # accounts (e.g., 'dev71') under the new AWS Control Tower.
        GREP_QA71_10_BOOTSTRAP_PROVIDERS_TF="grep -v 10-bootstrap/providers.tf"
        GREP_QA71_10_BOOTSTRAP_VARIABLES_TF="grep -v 10-bootstrap/variables.tf"
    else
        # But between other accounts (e.g., dev71 vs. prod71), it's still worth comparing.
        GREP_QA71_10_BOOTSTRAP_PROVIDERS_TF="cat"
        GREP_QA71_10_BOOTSTRAP_VARIABLES_TF="cat"
    fi

    # Recursively prints all file paths relative to current dir, but don't traverse into any nested '.terraform' directories,
    # and ignore file names like 'README.md', etc.
    # Finally, chop off ('sed') the leading root dir, leaving only the nested subdir/filenames.
    find ${DIR} -path '*/.terraform' -prune -false -o -name '*' -a -type f \
        | grep -v 'README.md' \
        | grep -v 'pictures' \
        | grep -v 'terraform.tf' \
        | grep -v 'terraform.tfstate' \
        | grep -v '.terraform.lock.hcl' \
        | grep -v 'kubeconfig_eks-' \
        | grep -v '.DS_Store' \
        | grep -v '21-transit-gateway-extra-routes.tf' \
        | grep -v 'admin/devops/40-eks1-bootstrap/05-secrets-manager-for-atlantis.tf' \
        | grep -v 'admin/devops/40-eks1-bootstrap/20-atlantis-secrets.tf' \
        | grep -v 'admin/devops/40-eks1-bootstrap/21-narvar-irsa-role-for-atlantis.tf' \
        | grep -v 'admin/devops/40-eks1-bootstrap/files/scripts/create_atlantis_secrets.sh' \
        | grep -v 'admin/devops/40-eks1-bootstrap/files/scripts/delete_atlantis_secrets.sh' \
        | ${GREP_DEVOPS_CONFIGMAP_TPL} \
        | ${GREP_ARGOCD} \
        | ${GREP_QA71_10_BOOTSTRAP_PROVIDERS_TF} \
        | ${GREP_QA71_10_BOOTSTRAP_VARIABLES_TF} \
        | sed "s#${DIR}/##"
}

compare_file_names() {
    # Recursively compare the file names (but not file content) between 2 directories.

    DIR1=$1
    DIR2=$2

    print_file_relative_paths ${DIR1} > ${TMP1_OUT}
    print_file_relative_paths ${DIR2} > ${TMP2_OUT}

    $DIFF ${TMP1_OUT} ${TMP2_OUT}

    if [ $? -ne 0 ]; then
        print_finding "The above are file names that are different between ${DIR1} (<) and ${DIR2} (>)."
        return 1
    fi
}

# compare_subdir_names() {
#     # Compare the immediate subdir names (but not recursing into nested subdirs) between 2 root dirs.
#
#     DIR1=$1
#     DIR2=$2
#
#     ls -1 ${DIR1} > ${TMP1_OUT}
#     ls -1 ${DIR2} > ${TMP2_OUT}
#
#     $DIFF ${TMP1_OUT} ${TMP2_OUT}
#
#     if [ $? -ne 0 ]; then
#         print_finding "The above are subdir names (non-recursive) that are different between ${DIR1} (<) and ${DIR2} (>)."
#         return 1
#     fi
# }

compare_file_content() {
    # Recursively compare the file content (for files with the same name) between 2 directories.

    DIR1=$1
    DIR2=$2

    for FILE_RELATIVE_PATH in $(print_file_relative_paths ${DIR1})
    do
        if [[ ! -f "${DIR2}/${FILE_RELATIVE_PATH}" ]]; then
            # If a matching file in DIR2 is missing (or vice versa), it would have been detected
            # by compare_file_names() earlier. So, now we don't need to report it (again).
            continue
        fi

        # https://unix.stackexchange.com/questions/157328/how-can-i-remove-all-comments-from-a-file#comment1279541_157619
        # Preprocess like this (before applying 'diff' next):
        #   1) Remove comment lines.
        #   2) Remove trailing comments that start in the middle of a line.
        #   3) Remove blank lines.
        sed '/^[[:blank:]]*#/d;s/[[:blank:]]*#.*//;/^[[:blank:]]*$/d' ${DIR1}/${FILE_RELATIVE_PATH} > ${TMP1_OUT}
        sed '/^[[:blank:]]*#/d;s/[[:blank:]]*#.*//;/^[[:blank:]]*$/d' ${DIR2}/${FILE_RELATIVE_PATH} > ${TMP2_OUT}

        if   [[ ${FILE_RELATIVE_PATH} =~ variables.tf ]]; then
            # Only compare variable names; don't compare variable values.
            $DIFF <(egrep 'variable '  ${TMP1_OUT}) \
                  <(egrep 'variable '  ${TMP2_OUT})

        elif [[ ${FILE_RELATIVE_PATH} =~ 30-flux-config-map-terraform-generated.tf ]]; then
            # Some lines contain account-specific attribute names; ignore those lines.
            # The string 'atlantis' only exist for 'devops', so ignore that outlier, too.
            $DIFF <(cat ${TMP1_OUT} | grep -v ${ACCT1_NAME} | grep -v atlantis) \
                  <(cat ${TMP2_OUT} | grep -v ${ACCT2_NAME} | grep -v atlantis)

        else
            $DIFF ${TMP1_OUT} ${TMP2_OUT}
        fi

        if [ $? -ne 0 ]; then
            print_finding "The above are content differences between ${DIR1}/${FILE_RELATIVE_PATH} (<) and ${DIR2}/${FILE_RELATIVE_PATH} (>)."
        fi
    done
}



if [[ "$#" -ne 2 ]]; then
   print_usage
   exit 1
fi

ACCT1_NAME=$1
ACCT2_NAME=$2

detect_devops_account
detect_qa71_account

check_terraform_src_dir ${ACCT1_NAME}
check_terraform_src_dir ${ACCT2_NAME}

ACCT1_DIR=$(print_terraform_src_dir ${ACCT1_NAME})
ACCT2_DIR=$(print_terraform_src_dir ${ACCT2_NAME})

TMP1_OUT=/tmp/diff.${ACCT1_NAME}.out
TMP2_OUT=/tmp/diff.${ACCT2_NAME}.out


# ... compare file names (but not contents) ..
compare_file_names   ${ACCT1_DIR} ${ACCT2_DIR}

# ... compare file contents ..................
compare_file_content ${ACCT1_DIR} ${ACCT2_DIR}

# .... clean up ..............................
/bin/rm -f $TMP1_OUT
/bin/rm -f $TMP2_OUT
