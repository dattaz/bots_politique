#!/bin/bash




for i in `tail -n +2 ${1}`
do
	echo ${i}
	ebooks archive ${i} corpus/${1}.json
	ebooks consume corpus/${i}.json
done
