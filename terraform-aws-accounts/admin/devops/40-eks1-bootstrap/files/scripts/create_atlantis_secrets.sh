# This script is obsolete.
# The stuff that were created by this script are now created via Kubernetes external-secrets
# which is deployed in Git repo 'flux-infra'.
# We keep this script file around (albeit in commented-out form) for now as a self-documenting
# way to show what the goal is.


    # print_usage() {
    #   cat <<EOF
    #     This script creates the Kubernetes 'kind: Secret' for Atlantis helm chart as referenced here:
    #     - "vcsSecretName": https://github.com/runatlantis/helm-charts
    #     - https://github.com/runatlantis/helm-charts/blob/b7945101d3d08bb3dafcd50150269bdb60e31094/charts/atlantis/templates/secret-webhook.yaml#L16-L19

    #     Usage:
    #         $0 VCS_SECRET_NAME GITCONFIG_SECRET_NAME
    #     Example:
    #         $0 atlantis-vcs-secret-for-github-webhook atlantis-gitconfig-for-fetching-terraform-private-modules

    #     The underlying command is:
    #         kubectl apply -f ...
    #     where the manifests are (multiple) 'kind: Secret'.

    #     Mandatory environment variables:
    #         - KUBECONFIG: The path to the kubeconfig file.
    #         - GITHUB_TOKEN
    #         - GITHUB_ATLANTIS_WEBHOOK_SECRET

    #     Note: If the content of the secret is changed (rather than the secret name), the Atlantis pod must be recreated in order to pick up the new content.
    #           To recreate the pod, do 'kubectl delete pod atlantis-0 -n atlantis' and let Kubernetes automatically recreate it.

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
    #   print_usage
    #   exit 1
    # fi

    # VCS_SECRET_NAME=$1
    # GITCONFIG_SECRET_NAME=$2

    # show_env

    # if [ -z "$KUBECONFIG"   ]; then echo "KUBECONFIG isn't set or is empty."; exit 1; fi

    #   ## In case "set -x" is in effect, disable it to avoid secrets being printed to stdout/stderr.
    # set +x && if [ -z "$GITHUB_TOKEN" ]; then echo "GITHUB_TOKEN  isn't set or is empty."; exit 1; fi
    # set +x && if [ -z "$GITHUB_ATLANTIS_WEBHOOK_SECRET" ]; then echo "GITHUB_ATLANTIS_WEBHOOK_SECRET isn't set or is empty."; exit 1; fi


    # # Must use 'echo -n' instead of 'echo'; otherwise, the NEWLINE char will be part of the secret which will be wrong, and the Atlantis pod
    # # will print the following errors upon startup:
    # #
    # #    {"level":"warn","ts":1638459511.8797197,"caller":"cmd/server.go:694","msg":"--gh-token contains a newline which is usually unintentional",...
    # #    {"level":"warn","ts":1638459511.8798664,"caller":"cmd/server.go:694","msg":"--gh-webhook-secret contains a newline which is usually unintentional",
    # #
    # # and upon receiving the Github webhook, the pod will print this error:
    # #    {"level":"warn","ts":1638460281.5305874,"caller":"logging/simple_logger.go:157","msg":"payload signature check failed",...
    # #
    # # A good launch of Atlantis should produce just a 1-line log during startup (without the above warnings):
    # #
    # #    $ kubectl -n atlantis logs -f atlantis-0
    # #    {"level":"info","ts":1638461827.3834949,"caller":"server/server.go:676","msg":"Atlantis started - listening on port 4141","json":{}}
    # #
    # # The out-of-the-box /usr/bin/base64 on the following platforms inserts a linebreak every 76 characters (!!!)
    # #       - ubuntu:20.04   (the Docker image we're building in this repo)
    # #       - Alpine Linux   (the Docker image for Atlantis)
    # #       - Amazon Linux 2 (default AMI for EC2)
    # #       - Default AMI for EKS nodes
    # #
    # # But linebreaks are significant in Yaml (and many other languages/formats).
    # # For example, yaml manifests for Kubernetes 'kind: Secret' contain base64 encoding.
    # #
    # # MacOS is an outlier. The /usr/bin/base64 on MacOS does NOT insert linebreaks. So, things that are working on
    # # a native Macbook will stop working when running almost anywhere else.

    # GITHUB_TOKEN_BASE64=$(echo -n ${GITHUB_TOKEN} | base64 --wrap=0)
    # GITHUB_ATLANTIS_WEBHOOK_SECRET_BASE64=$(echo -n ${GITHUB_ATLANTIS_WEBHOOK_SECRET} | base64 --wrap=0)

    # # This ends up to be the file ~/.gitconfig inside the Atlantis pod, and can be printed (after the Pod comes up) in Kubernetes like this:
    # #     $ kubectl exec -it atlantis-0 -n atlantis -- bash -c 'cat ~/.gitconfig'
    # #
    # # See Also:
    # #   - https://github.com/runatlantis/atlantis/issues/281#issuecomment-422171497
    # #   - https://github.com/runatlantis/helm-charts/blob/b7945101d3d08bb3dafcd50150269bdb60e31094/charts/atlantis/values.yaml#L64-L65
    # GITCONFIG_BASE64=$(cat <<EOF | base64 --wrap=0
    # [url "https://${GITHUB_TOKEN}@github.com"]
    #   insteadOf = ssh://git@github.com
    # EOF
    # )

    # NAMESPACE=atlantis

    # echo "Before ......"
    # set -x
    # kubectl get secrets -n $NAMESPACE

    # # "set +x" to ensure we don't print the manifest content (which contains secrets) to stdout/stderr
    # set +x; cat <<EOF | kubectl apply -f -
    # ---
    # apiVersion: v1
    # kind: Namespace
    # metadata:
    #   labels:
    #     namespace: $NAMESPACE
    #   name: $NAMESPACE

    # ---
    # apiVersion: v1
    # kind: Secret
    # metadata:
    #   name: ${VCS_SECRET_NAME}
    #   namespace: $NAMESPACE
    #   annotations:
    #     managed-by: terraform ($0)
    #     note1: "https://github.com/runatlantis/helm-charts/blob/b7945101d3d08bb3dafcd50150269bdb60e31094/charts/atlantis/values.yaml#L59"
    #     note2: "https://github.com/runatlantis/helm-charts/blob/main/charts/atlantis/templates/secret-webhook.yaml"
    #   labels:
    #     app: atlantis
    # data:
    #   github_token:  ${GITHUB_TOKEN_BASE64}
    #   github_secret: ${GITHUB_ATLANTIS_WEBHOOK_SECRET_BASE64}

    # ---
    # apiVersion: v1
    # kind: Secret
    # metadata:
    #   name: ${GITCONFIG_SECRET_NAME}
    #   namespace: $NAMESPACE
    #   annotations:
    #     managed-by: terraform ($0)
    #     note1: "https://github.com/runatlantis/atlantis/issues/281"
    #     note2: "https://github.com/runatlantis/helm-charts/blob/b7945101d3d08bb3dafcd50150269bdb60e31094/charts/atlantis/values.yaml#L75"
    #     note3: "https://github.com/runatlantis/helm-charts/blob/main/charts/atlantis/templates/secret-gitconfig.yaml"
    #   labels:
    #     app: atlantis
    # data:
    #   gitconfig: ${GITCONFIG_BASE64}
    # EOF

    # echo "After ......"
    # set -x
    # kubectl get secrets -n $NAMESPACE

