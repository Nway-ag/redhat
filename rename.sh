#!/bin/bash
#file: rename.sh
#use: rename .jpg and .png

count=1;
for img in *.jpg *.png
do
	new=image-$count.${img##*.}

	mv "$img" "$new"  2> /dev/null

	if [ $? -eq 0 ];then
		echo "Renaming $img to $new"
		let count++;
	fi

done


#######
# rename *.JPG *.jpg
# rename 's/ /_/g' *  替换文件名中空格为_
# rename 'y/A-Z/a-z/' * 替换文件名大小写
# rename 'y/a-z/A-Z/' *
