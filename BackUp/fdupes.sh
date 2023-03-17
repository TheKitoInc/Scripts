#!/bin/bash
find "$1" -depth -type d -exec fdupes -rdNI "{}" \;
