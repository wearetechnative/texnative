#!/usr/bin/env bash
#(C)2019-2022 Pim Snel - https://github.com/mipmip/RUNME.sh
ALLARGS=("$@");CMDS=();DESC=();NARGS=$#;ARG1=$1;make_command(){ CMDS+=($1);DESC+=("$2");};usage(){ printf "\nUsage: %s [command]\n\nCommands:\n" $0;line="              ";for((i=0;i<=$(( ${#CMDS[*]} -1));i++));do printf "  %s %s ${DESC[$i]}\n" ${CMDS[$i]} "${line:${#CMDS[$i]}}";done;echo;};runme(){ if test $NARGS -gt 0;then eval "$ARG1"||usage;else usage;fi;}

prepare(){
 if test $NARGS -lt 2; then
   echo "Usage: ./RUNME.sh ${ARG1} [./markdown_file.md]"
   exit 1
 fi

 MARKDOWNFILE=${ALLARGS[1]}
}

##### PLACE YOUR COMMANDS BELOW #####

make_command "render_auto" "auto render a markdown file on change"
render_auto(){
  prepare
  echo "Auto rendering. Press CTRL-C to quit."
  ls $MARKDOWNFILE | entr quarto render $MARKDOWNFILE
}

##### PLACE YOUR COMMANDS ABOVE #####

runme
