FROM alpine:3.11.6

# https://github.com/kubernetes/kubernetes/releases
ENV KUBE_VERSION="v1.18.2"
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v3.2.1"

RUN apk add --no-cache ca-certificates bash git openssl curl \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

CMD [ "bash" ]