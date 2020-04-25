#!/bin/bash
SCRIPTNAME="Raspberry Temperature Monitor"
VERSION="25-04-2020"
SCRIPTLOCATION="/usr/local/sbin/rpi-temp-monitor.sh"
PROFILELOCATION="/etc/profile.d/rpi-temp-monitor-alias.sh"

#
# Define function
#

UPDATE()
{
	# Getting info about the latest GitHub version
	NEW=$(curl -L --silent "https://github.com/Feriman22/raspberry-temperature-monitor/releases/latest" | awk '/<title>Release/ {print $4}')

	# Compare the installed and the GitHub stored version - Only internal, not available by any argument
	if [[ "$1" == "ONLYCHECK" ]] && [[ "$NEW" != "$VERSION" ]] && [[ "$NEW" =~ '-' ]]; then
		echo -e "New version ${GR}available!${NC}"
	else
		[[ "$1" == "ONLYCHECK" ]] && echo -e "The script is ${GR}up to date.${NC}"
	fi

	# Check the current installation
	if [[ "$1" != "ONLYCHECK" ]] && [ -f "$PROFILELOCATION" ] && [ -x "$SCRIPTLOCATION" ]; then

		# Check the GitHub - Is it available? - Exit if not
		[[ ! "$NEW" ]] && echo -e "GitHub is ${RED}not available now.${NC} Try again later." && exit

		# Compare the installed and the GitHub stored version
		if [[ "$NEW" != "$(awk '/VERSION=/' "$SCRIPTLOCATION" | grep -o -P '(?<=").*(?=")')" ]] && [[ "$NEW" =~ '-' ]]; then
			wget -q https://raw.githubusercontent.com/Feriman22/raspberry-temperature-monitor/master/rpi-temp-monitor.sh -O $SCRIPTLOCATION
			echo -e "Script has been ${GR}updated.${NC}"
		else
			echo -e "The script is ${GR}up to date.${NC}"
		fi
	else
		[[ "$1" != "ONLYCHECK" ]] && echo -e "Script ${RED}not installed.${NC} Install first then you can update it."
	fi
}


# Coloring
RED='\033[0;31m' # Red Color
GR='\033[0;32m' # Green Color
YL='\033[0;33m' # Yellow Color
NC='\033[0m' # No Color

# Print welcome text
echo -e "\n$SCRIPTNAME\n"
echo "Author: Feriman"
echo "URL: https://github.com/Feriman22/raspberry-temperature-monitor"
echo "Open GitHub page to read the manual and check new releases"
echo "Version: $VERSION"
UPDATE ONLYCHECK # Check new version
echo -e "${GR}If you found it useful, please donate via PayPal: https://paypal.me/BajzaFerenc${NC}\n"


# Call the menu
if [ "$1" == "-i" ] || [ "$1" == "-u" ] || [ "$1" == "-p" ] || [ "$1" == "--install" ] || [ "$1" == "--uninstall" ] || [ "$1" == "--portable" ] || [ "$1" == "-up" ] || [ "$1" == "--update" ]; then
	OPT="$1" && OPTL="$1" && ARG="YES"
else
	# Check the script is installed or not. Print the correct menu
	if [ -f "$PROFILELOCATION" ] && [ -x "$SCRIPTLOCATION" ]; then
		# The script is installed
		PS3='Please enter your choice: '
		options=("Run the monitor (any user)" "Uninstall (only root)" "Update (only root)" "Quit")
		select opt in "${options[@]}"
		do
			case $opt in
				"Run the monitor (any user)")
					OPT='-p' && OPTL='--portable' && break
					;;
				"Uninstall (only root)")
					OPT='-u' && OPTL='--uninstall' && break
					;;
				"Update (only root)")
					OPT='-up' && OPTL='--update' && break
					;;
				"Quit")
					break
					;;
				*) echo "Invalid option $REPLY";;
			esac
		done
	else
		# The script is not installed.
		PS3='Please enter your choice: '
		options=("Portable (any user)" "Install (only root)" "Quit")
		select opt in "${options[@]}"
		do
			case $opt in
				"Portable (any user)")
					OPT='-p' && OPTL='--portable' && break
					;;
				"Install (only root)")
					OPT='-i' && OPTL='--install' && break
					;;
				"Quit")
					break
					;;
				*) echo "Invalid option $REPLY";;
			esac
		done
	fi
fi


##
########### Choosed the Portable or Run the monitor ###########
##

if [ "$OPT" == '-p' ] || [ "$OPTL" == '--portable' ]; then
	PS3='There is three options. Please enter your choice: '
	OPT1="Live Watch - Refresh every 0.2 sec"
	OPT2="Write to terminal - Refresh every 2 sec"
	OPT3="Quit"

	options=("$OPT1" "$OPT2" "$OPT3")
	select opt in "${options[@]}"
	do
		case $opt in
			"$(echo $OPT1)")
				watch -n 0.2 /opt/vc/bin/vcgencmd measure_temp
				;;
			"$(echo $OPT2)")
				echo -e "Press Ctrl + C to exit.\n"
				while [[ 1 = 1 ]]; do
				/opt/vc/bin/vcgencmd measure_temp | cut -c 6-
				date
				echo
				sleep 2
				done
				;;
			"$(echo $OPT3)")
				break
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
fi


##
########### Choosed the Install ###########
##

if [ "$OPT" == '-i' ] || [ "$OPTL" == '--install' ]; then

	# Check the root permission
	[ ! $(id -u) = 0 ] && echo -e "${RED}Run as root!${NC} Exiting...\n" && exit

	#
	### Start Installation ###
	#

	# Start count the time of install process
	SECONDS=0

	# Set alias in profile for all users
	STRING="alias temp="$SCRIPTLOCATION"" # Used for root as well
	if [ ! -f "$PROFILELOCATION" ]; then
		echo -e "$STRING\nalias sudo='sudo '" > "$PROFILELOCATION"
		chmod +x "$PROFILELOCATION"
		echo -e "\nAlias has been set for all users. ${GR}OK.${NC}"
	else
		echo -e "\nAlias ${GR}already set for all users.${NC}"
	fi
	
	# Set alias in bashrc for root
	STRING="alias temp="$SCRIPTLOCATION""
	if [ $(grep -c "$STRING" /root/.bashrc) -lt "1" ]; then
		echo "$STRING" >> /root/.bashrc
		echo -e "Alias has been set for root. ${GR}OK.${NC}"
	else
		echo -e "Alias ${GR}already set for root.${NC}"
	fi

	# Copy the script to $SCRIPTLOCATION and add execute permission
	if [ "$(dirname "$0")/$(basename "$0")" != "$SCRIPTLOCATION" ]; then
		/bin/cp -rf "$0" /usr/local/sbin && chmod +x "$SCRIPTLOCATION" && echo -e "This script has been copied in $SCRIPTLOCATION ${GR}OK.${NC}"
	else
		echo -e "The script already copied to destination or has been updated. Nothing to do. ${GR}OK.${NC}"
	fi

	# Print warning if the alias is active set yet
	bash -ixlc : 2>&1 | grep temp > /dev/null && echo -e "\n${YL}WARNING!${NC} Restart session or run this below command is required to activate temp command:\n. /root/.bashrc\n"

	# Happy ending.
	echo -e "${GR}Done.${NC} Full install time was $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"

fi


##
########### Choosed the Uninstall ###########
##

if [ "$OPT" == '-u' ] || [ "$OPTL" == '--uninstall' ]; then

	# Check the root permission
	[ ! $(id -u) = 0 ] && echo -e "${RED}Run as root!${NC} Exiting...\n" && exit

	if [ "$ARG" != 'YES' ]; then
		loop=true;
		while $loop; do
			echo -e "${RED}UNINSTALL${NC} $SCRIPTNAME on $(hostname).\n"
			read -p "Are you sure? [Y/n]: " var1
			loop=false;
			if [ "$var1" == 'Y' ] || [ "$var1" == 'y' ]; then
				echo -e "Okay! You have 5 sec until start the ${RED}UNINSTALL${NC} process on $(hostname). Press Ctrl + C to exit.\n"
				for i in {5..1}; do echo $i && sleep 1; done
			elif [ "$var1" == 'n' ]; then
				echo "Okay, exit."
				exit
			else
				echo "Enter a valid response Y or n";
				loop=true;
			fi
		done
	fi

	#
	### Starting Uninstall ###
	#

	# Remove profile file
	if [ -f "$PROFILELOCATION" ]; then
		rm -r "$PROFILELOCATION"
		echo -e "\nAlias removed for all users. ${GR}OK.${NC}"
	else
		echo -e "\nAlias not found for all users. ${GR}OK.${NC}"
	fi
	
	# Remove alias in .bashrc
	if [ $(grep -c "$SCRIPTLOCATION" /root/.bashrc) -gt "0" ]; then
		sed -i '/alias temp=/d' /root/.bashrc
		echo -e "Alias removed for root. ${GR}OK.${NC}"
	else
		echo -e "Alias not found for root. ${GR}OK.${NC}"
	fi
	
	# Remove the script
	[ -f "$SCRIPTLOCATION" ] && rm -f "$SCRIPTLOCATION" && echo -e "The script removed. ${GR}OK.${NC}" || echo -e "Script not found. ${GR}OK.${NC}"

fi


##
########### Choosed the Update ###########
##

if [ "$OPT" == '-up' ] || [ "$OPTL" == '--update' ]; then

	# Check the root permission
	[ ! $(id -u) = 0 ] && echo -e "${RED}Run as root!${NC} Exiting...\n" && exit
	UPDATE

fi