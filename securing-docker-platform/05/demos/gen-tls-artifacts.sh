#!/bin/bash


users=(baxter bolt rackham)


export DOCKER_HOST=tcp://wolff:2376
export DOCKER_TLS_VERIFY=1


cfssl () {
    docker container run -i --rm -u $UID:$UID -v $PWD:/pki -w "/pki" --userns=host cfssl/cfssl "$@"
}


cfssljson() {
    docker container run -i --rm -u $UID:$UID -v $PWD:/pki -w "/pki" --userns=host --entrypoint cfssljson cfssl/cfssl "$@"
}


for user in "${users[@]}"; do
    CERT_PATH="/home/${user}/.docker"
    cp client-csr.json ${user}-csr.json
    sed -i "s/client/$user/" ${user}-csr.json
    printf "\nGenerating TLS artefacts for $user ...\n\n"
    cfssl gencert \
        -ca=ca.pem -ca-key=ca-key.pem -config ca-config.json \
        -profile=client \
        ${user}-csr.json | cfssljson -bare $user -
    mv ${user}-key.pem key.pem
    mv ${user}.pem cert.pem
    sudo mkdir -p $CERT_PATH && sudo chown ${user}.${user} $CERT_PATH
    printf "\nCopying TLS artefacts to $CERT_PATH ..."
    sudo cp {ca,cert,key}.pem $CERT_PATH
    sudo chown ${user}.${user} ${CERT_PATH}/{ca,cert,key}.pem
    sudo chmod 0400 ${CERT_PATH}/{ca,cert,key}.pem
    printf " Done\n\n"
done
