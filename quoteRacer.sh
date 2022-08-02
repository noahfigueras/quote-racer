#!/usr/bin/bash

name="QUOTE RACER"
selected='play'

print_menu() {
	if [ $selected == "play" ]; then
		printf "%20s\e[1;32;4m%s\e[0m  |  %s\n" " " "PLAY GAME" "EXIT GAME"
	else 
		printf "%20s%s  |  \e[1;32;4m%s\e[0m\n" " " "PLAY GAME" "EXIT GAME"
	fi
}

toggle_menu() {
	if [ $selected == 'play' ]; then
		selected='exit'
	else 
		selected='play'
	fi
}

play() {
	position=0
	errors=0
	quoteln=$(random_quote)
	quote=$(sed "${quoteln}q;d" quotes.txt)
	author=$(sed "$[quoteln+1]q;d" quotes.txt)
	start=$(date +%s)
	while [ ${#quote} -gt $position ];
	do
		clear
		# Print highlighted quote
		printf "\e[1;32m${quote:0:$position}\e[0m\e[1;41m${quote:$position:$errors}\e[0m${quote:$[position+errors]}"
		printf "\n\n${author}"
		# Get char
		pos=${quote:$position:1}
		# Read input char
		read -n 1 -s key
		# Handle spaces
		if [ "$key" = "" ]; then
			key=" " 
		fi
		# Compare chars
		if [ "$pos" == "$key" ] && [ $errors -eq 0 ]; then
			position=$[position + 1]	
		# Handle backspaces
		elif [ "$key" = $'\177' ]; then
			if [ $errors -ne 0 ]; then
				errors=$[errors - 1]
			fi
		else 
			errors=$[errors + 1]
		fi
	done
	# Calculate WPM
	words=$((${#quote}/5))
	end=$(date +%s)
	time_diff=$((end-start))
	wpm=$(echo "print(round(${words}/(${time_diff}/60)))" | python3)
	printf "\n\n\e[1;36m${wpm} WPM \e[0m is your typing speed"
	sleep 3
	# Go to menu
	selected='play'
}

random_quote() {
	counter=0
	# Get File length
	while read line;
	do
		counter=$[counter + 1]
	done < quotes.txt
	# Get quote randomly
	random=$[RANDOM % (counter-1) + 1]
	if [ $[random % 2] -ne 0 ]; then 
		echo $random
	else
		echo $[random+1]
	fi
}

select_opt() {
	if [ $selected == 'play' ]; then
		selected='playing'
		play
	elif [ $selected == 'exit' ]; then
		clear
		exit 0	
	fi
}

reset() {
	clear
	printf "%s \n" "$(figlet QUOTE RACER)" 
}

# Menu
while :
do
	reset
	if [ $selected == 'playing' ]; then
		play
	else
		print_menu
	fi

	# Menu selection
	read -n 1 -s key
	case $key in
		"h")
			toggle_menu
			;;
		"l")
			toggle_menu
			;;
		"s")
			select_opt	
			;;
	esac
done

