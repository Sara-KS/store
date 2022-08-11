WORKDIR=$(mktemp -d) && cd $WORKDIR

GITHUB=github.com
#ORG=IBM
ORG=starpit
REPO=multi-cluster-app-dispatcher
#BRANCH=quota-management
BRANCH=helm3-qm
SUBDIR=deployment/mcad-controller

echo "Installing Enhanced Scheduler"

# sparse clone
if [ -n "$BRANCH" ]; then BRANCHOPT="-b $BRANCH"; fi
(git clone -q --filter=tree:0 --depth 1 --sparse https://${GITHUB}/${ORG}/${REPO}.git ${BRANCHOPT} > /dev/null && \
    cd $REPO && \
    git sparse-checkout init --cone > /dev/null && \
    git sparse-checkout set $SUBDIR > /dev/null)

IMAGE=darroyo/mcad-controller
cd $REPO/$SUBDIR &&
    helm upgrade --install --wait mcad . \
         ${KUBE_CONTEXT_ARG_HELM} \
         --namespace kube-system \
         --set loglevel=4 \
         --set image.repository=$IMAGE \
         --set image.tag=quota-management-v1.29.40 \
         --set image.pullPolicy=IfNotPresent \
         --set configMap.name=mcad-controller-configmap \
         --set configMap.quotaEnabled='"false"' \
         --set coscheduler.rbac.apiGroup="scheduling.sigs.k8s.io" \
         --set coscheduler.rbac.resource="podgroups"
