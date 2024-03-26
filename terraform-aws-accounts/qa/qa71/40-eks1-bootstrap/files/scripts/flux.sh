print_usage() {
   cat <<EOF
    This script runs 'flux bootstrap ...' 

    Usage:
        $0 OWNER REPO BRANCH REPO_PATH
    Example:
        $0 narvar flux-infra master ./clusters/aws/admin/devops

    The underlying command is:
        flux bootstrap github --owner OWNER --repository=REPO --branch=BRANCH --path=REPO_PATH

    Environment variables:
        - KUBECONFIG: The path to the kubeconfig file.
        - GITHUB_USER
        - GITHUB_TOKEN

EOF
}

show_env() {
    echo "pwd=`pwd`"

    # Caution: Don't print out GITHUB_TOKEN or other secrets.
    env | grep -e KUBECONFIG -e GITHUB_USER -e AWS

    ls -l $KUBECONFIG
}


# ........................................ main ........................................
set -e

if [[ "$#" -ne 4 ]]; then
   print_usage
   exit 1
fi

OWNER=$1
REPO=$2
BRANCH=$3
REPO_PATH=$4

show_env

if [ -z "$KUBECONFIG"   ]; then echo "KUBECONFIG   isn't set or is empty."; exit 1; fi
if [ -z "$GITHUB_USER"  ]; then echo "GITHUB_USER  isn't set or is empty."; exit 1; fi

  ## In case "set -x" is in effect, disable it to avoid secrets being printed to stdout/stderr.
set +x && if [ -z "$GITHUB_TOKEN" ]; then echo "GITHUB_TOKEN isn't set or is empty."; exit 1; fi

set -x
# The version of flux should be the same as that in:
#   - https://github.com/narvar/foundation-local-env/blob/master/Dockerfile
flux bootstrap github --owner=$OWNER --repository=$REPO --branch=$BRANCH --path=$REPO_PATH
