#!/bin/bash

now=$(date +"%d-%m-%Y-%T")
echo "${now}"

# test your code for security issues (optional debug mode = -d)
snyk code test --json | snyk-to-html -d > "${now}"-snyk-code.html && open "${now}"-snyk-code.html
