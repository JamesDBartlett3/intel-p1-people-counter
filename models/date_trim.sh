#!/bin/bash

# Removes 11 characters and a trailing slash (if exists) 
# from the end of the given file or folder name

pretrim=${@%/}
mv $pretrim ${pretrim::(-11)}