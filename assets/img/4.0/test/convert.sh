#!/bin/sh
for img in *.png ; 
do 
	convert -resize 128x90 "$img" "resized/$img" 
done

