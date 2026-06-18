#!/bin/bash

sort accessi.txt | uniq -c | sort -r | head -n 3

