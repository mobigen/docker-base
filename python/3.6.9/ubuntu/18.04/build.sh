#!/bin/bash

workingDir=$(dirname $0)
docker build -f $workingDir/Dockerfile --tag repo.iris.tools/base/python:3.6.9-ubuntu-18.04 .
