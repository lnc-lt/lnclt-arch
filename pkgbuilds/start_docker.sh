#!/usr/bin/env bash

docker run -v "$(pwd)/repo:/app/repo" lnclt/arch-repo:latest
