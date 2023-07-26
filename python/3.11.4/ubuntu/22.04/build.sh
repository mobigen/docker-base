#!/bin/bash

workingDir=$(dirname $0)
docker build -f $workingDir/Dockerfile --tag repo.iris.tools/base/python:3.11-ubuntu-22.04 .
