emulator=${1}
gamelist_org_file="${emulator}/gamelist.xml"
gamelist_full_ko_file="${emulator}/gamelist.ko.all.xml"
mygamelist="${emulator}/mygamelist.txt"

[ $# -eq 0 ] && { 
  echo "Usage: $0 romfolder [arcade, snes, megadrive, pcengine, etc] "; exit 1; 
}

function main() {
  # check if file is food.xml
  if [ -f $gamelist_org_file ] && [ -f $gamelist_full_ko_file ] && [ -f $mygamelist ]; then
    
    # backup gamelist.xml  
    $(cp ${emulator}/gamelist.xml ${emulator}/gamelist.xml.bak)

    # clear up error log file
    $(cat /dev/null > log/error.log)

    readMyGameList

  else
    echo "Usage: $0 romfolder [arcade, snes, megadrive, pcengine, etc] ";
    echo "Please check the usage and required files";
    exit 1; 
  fi
}

# read my gamelist
function readMyGameList() {
    while read line
    do 
      if [ ! -e "/home/pi/RetroPie/roms/${emulator}/${line}" ]
      then
        echo "${line} rom file not exist!!" | tee -a log/error.log # print screen and write log
        continue # skip next parts
      fi

      #echo $line
      let matchCount=$(xmlstarlet sel -t -c "count(//gameList/game[path[text()='./$line.zip']])" $gamelist_org_file)

      if [ $matchCount -ge 1 ]
      then
          echo "${line}.zip game already exist in gamelist_org_file" >> "log/error.log"
      else
          getSpecificGameMetadata "./${line}.zip"
      fi
    done < $mygamelist
}

# get specific game metadata
function getSpecificGameMetadata() {
  #let matchCount=$(xmllint --xpath "count(//gameList/game[path[text()='$1']])" $gamelist_full_ko_file)
  let matchCount=$(xmlstarlet sel -t -c "count(//gameList/game[path[text()='$1']])" $gamelist_full_ko_file)

  if [ $matchCount -eq 1 ] 
  then
    # echo "find ${1} in gamelist_all_file"
    # echo "get node of ${1}"
    #echo $(xmllint --xpath "//gameList/game[path[text()='$1']]" $gamelist_full_ko_file)
    local gameNode=$(xmlstarlet sel -t -c "//gameList/game[path[text()='$1']]" $gamelist_full_ko_file)

    addNewGameNode "${gameNode}" ${1:2}
  elif [ $matchCount -gt 1 ]
  then 
    echo "match count greater than 1, please check file." 
  else
	    echo "${1} game is not exist in gamelist_all_file" >> "log/error.log"
  fi 
}

# add new game node
function addNewGameNode() {
  #$(xml ed -O -N xsi=http://www.w3.org/2001/XMLSchema-instance -d "/xsi:gameList/game[1]" $gamelist_org_file)

  # update gamelist.xml  
  python xmlparsing.py "${1}" ${emulator}

  echo "${2} game added in gamelist successfully"
}

# get file names
function processBookstore() {
  let gameCount=$(xmllint --xpath 'count(//gameList/game)' $gamelist_org_file) 
 
  for (( i=1; i <= $gameCount; i++ )); do 
    local file_path=$(xmllint --xpath '//gameList/game['$i']/path/text()' $gamelist_org_file)
    echo ${file_path:2}
  done
}

main
