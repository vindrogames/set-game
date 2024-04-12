#!/bin/sh
for img in *.png ; 
do 
	convert -resize 140x100 "$img" "resized/$img" 
done

