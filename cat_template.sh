#!/bin/bash

cd src/contestlib/

cat imports.nim
cat core.nim io.nim | \grep -v "import"
