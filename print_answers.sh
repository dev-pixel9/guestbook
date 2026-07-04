#!/bin/bash

# Clear screen
clear

echo "=========================================================="
echo "          GUESTBOOK PROJECT SUBMISSION ANSWERS            "
echo "=========================================================="
echo ""

# List of files in correct order
files=("Dockerfile" "crimages" "app" "hpa" "hpa2" "upguestbook" "deployment" "up-app" "rev" "rs")

for f in "${files[@]}"; do
  echo "=========================================================="
  echo ">>> SUBMISSION FILE: $f"
  echo "=========================================================="
  if [ -f "$f" ]; then
    cat "$f"
  else
    echo "Warning: File '$f' not found! Please run ./run_project.sh first."
  fi
  echo ""
  echo ""
done
