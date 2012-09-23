#!/bin/bash

# extdiff executes diff automatically excluding all files
# that do not match the file extensions passed as argument
# -- by Joao Cordeiro
#
# example:
# extdiff -Naur ./oldcode ./newcode "*\.cpp$"
# will perform the diff between both folders, excluding all files that do not have th .cpp extension

## check the number of arguments
if [ $# -lt 3 ]; then
   echo "usage: $0 [diff-options] path1 path2 exclude-expression"
   exit 1
fi


## set the variables from the arguments
flags=${@:1:$(($#-3))}
path1=${BASH_ARGV[2]}
path2=${BASH_ARGV[1]}
regex=${BASH_ARGV[0]}


## check that path1 and path2 exist
if [ ! -e "$path1" ]
then
   echo "$path1 not found."
   exit 1
fi

if [ ! -e "$path2" ]
then
   echo "$path2 not found."
   exit 1
fi

## create a temporary file to host the patterns to exclude
tmpfile=""
for i in {1..500}
do
   tmpfile="/tmp/extdiff.tmp.""$i"

   if [ ! -e "$tmpfile" ]
   then
      touch "$tmpfile"
      break
   else
      tmpfile=""
   fi
done


## make sure it was possible to create the temporary file
if [ "$tmpfile" == "" ]
then
   echo "Could not create a temporary file. Aborting."
   exit 1
fi

## get the list of files to ignore by filtering the regex out of all the existing files
for f in $(find $path1 $path2 -type f -exec basename {} \; | sort | uniq);
do
   match=`echo $f | egrep $regex`
   if [ "$match" == "" ]
   then
#      echo "[ ]" $f
      echo $f >> $tmpfile
#   else
#      echo "[*]" $f
   fi
done
#echo


## perform the diff using the temporary file to exclude files
diff --exclude-from=$tmpfile $flags $path1 $path2


## remove the temporary file created earlier
if [ ! -e "$tmpfile" ]
then
   echo "WARNING: Can't delete temporary file."
   exit 1
else
   rm $tmpfile
fi
