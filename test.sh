#!/bin/bash

cd $(dirname "$0")

echo "will run ./text-search-count $@"

./build text-search.cu clean build && time ./text-search $@ < ../tests/large-test-many-patterns.in > large-test-many-patterns.out
