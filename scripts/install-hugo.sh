#!/bin/bash -ex
HUGO_VERSION=0.15
wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux_amd64.tar.gz
tar xvzf hugo_${HUGO_VERSION}_linux_amd64.tar.gz
cp hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64 hugo
