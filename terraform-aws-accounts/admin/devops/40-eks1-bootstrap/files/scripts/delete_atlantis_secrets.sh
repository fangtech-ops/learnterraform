# This script is obsolete.
# See comments in ./create_atlantis_secrets.sh


        # print_usage() {
        # cat <<EOF
        #     Usage:
        #         $0 VCS_SECRET_NAME GITCONFIG_SECRET_NAME
        #     Example:
        #         $0 atlantis-vcs-secret-for-github-webhook atlantis-gitconfig-for-fetching-terraform-private-modules

        #     The underlying command is:
        #         kubectl delete secret ...
        # EOF
        # }

        # show_env() {
        #     echo "pwd=`pwd`"

        #     # Caution: Don't print out GITHUB_TOKEN or other secrets.
        #     env | grep -e KUBECONFIG

        #     ls -l $KUBECONFIG
        # }


        # # ........................................ main ........................................
        # set -e

        # if [[ "$#" -ne 2 ]]; then
        # print_usage
        # exit 1
        # fi

        # VCS_SECRET_NAME=$1
        # GITCONFIG_SECRET_NAME=$2

        # show_env

        # if [ -z "$KUBECONFIG"   ]; then echo "KUBECONFIG   isn't set or is empty."; exit 1; fi

        # NAMESPACE=atlantis

        # echo "Before ......"
        # set -x
        # kubectl -n $NAMESPACE get secrets

        # kubectl -n $NAMESPACE delete secret $VCS_SECRET_NAME       --ignore-not-found=true
        # kubectl -n $NAMESPACE delete secret $GITCONFIG_SECRET_NAME --ignore-not-found=true

        # echo "After ......"
        # set -x
        # kubectl -n $NAMESPACE get secrets

