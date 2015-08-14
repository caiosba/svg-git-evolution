#!/bin/bash
# svg-git-evolution.sh
# A Bash script that generates a video showing the evolution of an SVG image inside a Git repository
# Requirements: git, inkscape, imagemagick, mktemp, ffmpeg

path=$1
if [ -z $path ]
then
  echo "Usage: ./svg-git-evolution.sh <path to SVG inside Git repository> <video size (WxH, default 800x600)> <image duration (seconds, default 5)> <effect (fade|default)>"
  exit 0
fi
size=$2
if [ -z $size ]
then
  size=800x600
fi
dur=$3
if [ -z $dur ]
then
  dur=5
fi
effect=$4
if [ -z $effect ]
then
  effect=default
fi

output=$(mktemp -d)

i=0
j=0

# Hack to avoid the subshell scope of variables
loop=$(mktemp)
filter=$(mktemp)
concat=$(mktemp)
last=$(mktemp)
images=$(mktemp)

git log --pretty=%H --name-only --follow $path | while read line
do
  if [ "$line" != "" ]
  then
    if ! ((i % 2))
    then
      commit=$line
    else
      file=$line
      git show $commit:$file > $output/$j.svg
      inkscape -e=$output/$j.png -D -b=#ffffff $output/$j.svg >/dev/null 2>/dev/null
      date=$(git show --format=%aD --pretty=%aD -s $commit)
      convert $output/$j.png -gravity Southeast -pointsize 30 -fill black -stroke black -strokewidth 1 -annotate +10+10 "$date" $output/$j.png
      convert $output/$j.png -resize $size -background white -gravity center -extent $size $output/$j.png
      rm $output/$j.svg

      # Default transition
      echo -n " $output/$j.png $(cat $images) " > $images

      # Fade effect
      echo -n " -loop 1 -t 1 -i $output/$j.png $(cat $loop) " > $loop
      if [[ $j -gt 0 ]]
      then
        k=$((j-1))
        echo -n " $(cat $filter) [$j:v][$k:v]blend=all_expr='A*(if(gte(T,$dur),1,T/$dur))+B*(1-(if(gte(T,$dur),1,T/$dur)))'[b${j}v]; " > $filter
        echo -n "$(cat $concat)[$k:v][b${j}v]" > $concat
        n=$((2 * j + 1))
        echo -n "[$j:v]concat=n=$n" > $last
      fi

      j=$((j+1))
    fi
    i=$((i+1))
  fi
done

outfile="$(basename $path | sed 's/\.svg$//g').mp4"
rm -f $outfile

if [ "$effect" == "fade" ]
then
  ffmpeg $(cat $loop) -filter_complex "$(cat $filter)$(cat $concat)$(cat $last):v=1:a=0,format=yuv420p[v]" -map "[v]" $outfile >/dev/null 2>/dev/null
else
  cat $(cat $images) | ffmpeg -f image2pipe -r 1/$dur -vcodec png -i - -vcodec libx264 $outfile >/dev/null 2>/dev/null
fi

rm -rf $output $loop $filter $concat $last $images

echo "Your video is at $outfile"
