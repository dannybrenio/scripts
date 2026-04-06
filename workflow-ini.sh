#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] ||[ -z "$3" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	echo "Try $0 -h or $0 -help to show guide:"
	echo "Usage: $0 <mode> <folder> <tmux-mode>" 
	echo "mode : web | local" 
	echo "folder : existing folder name inside <mode>, or new folder will be created" 
	echo "tmux-mode: muxone = one pane, muxtwo = two panes, muxthree = three panes"
	exit
fi

echo "Hello" $(whoami)"!"

sleep 1
echo "Checking Internet Connectivity..."

sleep 1
if ping -c 1 google.com > /dev/null 2>&1; then
	echo "Network connected to $(iwgetid -r)"
else 
	echo "Network disconnected, terminating process"
	exit
fi

sleep 1

echo "Checking if MySQL is running"
while sudo /opt/lampp/lampp status 2>&1 | grep -q "MySQL is not running"; do
	echo "PhpMyAdmin is not running...starting"
	sudo /opt/lampp/lampp start > /dev/null 2>&1
	sleep 5
done


echo "PhpMyAdmin is now running"

	
folderPath="/home/danny/projects/"
classification="$1"
classPath="${folderPath}${classification}"

sleep 1

while true ; do
	if [ -d "$classPath" ]; then
		echo "Classification: '$classification'"
		break
	else 
		echo "This classification does not exist(local or web)"
		echo "Enter classification"
		read classification
		classPath="${folderPath}${classification}"
	fi
done

project="/$2"
projPath="${classPath}${project}"
echo "Project Path: " $projPath

sleep 3

echo "Initializing session..."

sleep 2

tmuxCreate(){
	tmux new-session -d -s dev -c "$projPath"
}

tmuxSplitHori(){
	tmux split-window -h -c "$projPath"
}

tmuxToFirstPane(){
	tmux select-pane -t 0
}

gitIniChecker(){	
	if [ -d "$projPath/.git" ]; then
		echo "Found git ini file"
		tmux send-keys "git status" C-m
	elseif
		echo "No git ini file"
	fi
}
tmuxSplitVert(){
	tmux split-window -v -c "$projPath"
	}

tmuxSendKeys(){
	tmux send-keys "nvim" C-m
}

tmuxRightPane1(){
	tmux select-pane -t 1
	tmux send-keys "nvim" C-m
}

tmuxRightPane2(){
	tmux select-pane -t 2
	tmux send-keys "nvim" C-m
}

tmuxAttach(){
	tmux attach -t dev
}

tmuxPreset="$3"
runTmuxPreset(){
case "$tmuxPreset" in 
	"muxone")
		tmuxCreate
		tmuxSendKeys
	;;
	"muxtwo")
		tmuxCreate
		tmuxSplitHori
		tmuxToFirstPane
		gitIniChecker
		tmuxRightPane1

	;;
	"muxthree")
		tmuxCreate
		tmuxSplitHori
		tmuxToFirstPane
		gitIniChecker
		tmuxSplitVert
		tmuxRightPane2
	
	;;
	*)
		echo "Wrong tmux command using muxone as default"
		tmuxCreate
		tmuxSendKeys
	;;
esac
}



reportLog(){
	logfile="report.txt" 
	# finds the header and checks if it exists
	if [ ! -f "$logfile" ] || ! grep -q "^DATE" "$logfile"; then 
		printf "%-20s %-10s %-15s %-15s %-15s %-15s\n" \
		"DATE" "USER" "NETWORK" "CLASS" "PROJECT" "PROFILE" >> "$logfile" 
	fi

logTimestamp=$(date '+%Y-%m-%d %H:%M:%S')
logUser=$(whoami)
logWNet=$(iwgetid -r)
logClassification=$classification
logProjectFolder=$project
logTmuxProfile=$tmuxPreset

# append one row
printf "%-20s %-10s %-15s %-15s %-15s %-15s \n" \
	"$logTimestamp" "$logUser" "$logWNet" "$logClassification" "$logProjectFolder" "$logTmuxProfile" >> "$logfile"

}

while [ ! -d $projPath ] ;do
        echo "Project Folder not found"
	echo -n "Create a new folder?(y or n)"
	read projectChecker

	if [ "$projectChecker" == "y" ]; then
		echo -n "Enter folder name: "
		read newFolder 
		projPath="${classPath}/${newFolder}"
	     	mkdir "$projPath"
	     	cd "$projPath"	
		runTmuxPreset
		reportLog
		tmuxAttach
		exit 0
	else
		echo "Exiting script no folder found..."
		exit
	fi
done

runTmuxPreset
reportLog
tmuxAttach
