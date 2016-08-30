#!/bin/bash
#This script is fundamentally aimed at finding out whether you have installed one or more non-free/libre Arch 
#Linux packages. It takes Parabola's blacklists to perform the test. These blacklists may
#be found in: 
#  https://git.parabola.nu/blacklist.git/plain/blacklist.txt 
#or, for the AUR blacklist: 
#  https://git.parabola.nu/blacklist.git/plain/aur-blacklist.txt
#or, for the privacy blacklist:
#  https://git.parabola.nu/blacklist.git/plain/your-privacy-blacklist.txt
#Note: GitHub (https://github.com/duckinator/check-free.git) has a script called 'check-free' 
#(written by Nick Marwell (duckinator)), which is intended to do the same thing this script does. 
#However, I'm not sure whether it works so fine, since it only recognizes, provided my script does the 
#job fine, 6 of MY 33 non-free/libre packages.

#More Parabola's blacklists:
#emulator-blacklist: https://git.parabola.nu/blacklist.git/plain/your-freedom_emu-blacklist.txt

###COLORS###
white="\033[1;37m"
red="\033[1;31m"
yellow="\033[1;33m"
green="\033[1;32m"
cyan="\033[1;36m"
blue="\033[1;34m"
#d_red="\033[0;31m"
#d_yellow="\033[0;33m"
#d_cyan="\033[0;36m"
#d_green="\033[0;32m"
nc="\033[0m"

###FUNCTIONS###
function get_blacklist ()
{
   if [[ $1 == "aur" ]]; then
      echo -n "Downloading Parabola's AUR blacklist... "
      curl -s https://git.parabola.nu/blacklist.git/plain/aur-blacklist.txt | sed 's/  //g' > /tmp/parabola_bl.txt   
   elif [[ $1 == "privacy" ]]; then
      echo -n "Downloading Parabola's privacy blacklist... "
      curl -s https://git.parabola.nu/blacklist.git/plain/your-privacy-blacklist.txt | sed 's/  //g' > /tmp/parabola_bl.txt
   else
      echo -n "Downloading Parabola's blacklist... "
      curl -s https://git.parabola.nu/blacklist.git/plain/blacklist.txt | sed 's/  //g' > /tmp/parabola_bl.txt
   fi
   while read line; do
      blacklist[${#blacklist[@]}]=$line
   done < /tmp/parabola_bl.txt
   echo -e "${green}Done$nc" && sleep 1   
}

function blacklist_line ()
{
   export GREP_COLOR='1;36'
   pack=$1; counter=$2;
   bl_line=$(cat /tmp/parabola_bl.txt | grep ^${pack}:)
   case $bl_line in
       *\[technical\]*|*\[branding\]*|*\[recommends-nonfree\]*|points\ to\ nonfree) echo -ne "${white}$counter$nc - ${green}${pack}: $nc" && technical=$((technical+1));;
       *\[nonfree\]*) echo -ne "${white}$counter$nc - ${red}${pack}: $nc" && nonfree=$((nonfree+1));;
       *\[semifree\]*|*\[uses-nonfree\]*|*\[use-nonfree\]*) echo -ne "${white}$counter$nc - ${yellow}${pack}: $nc" && semifree=$((semifree+1));;
       *\[FIXME*) echo -ne "${white}$counter$nc - ${white}${pack}: $nc" && fix_doc=$((fix_doc+1));;
       *) echo -ne "${white}$counter$nc - ${blue}${pack}: $nc\n" && no_desc=$((no_desc+1));;
   esac
#   echo "$bl_line" | grep --color -P '(?<=\[).*(?=\] .?)'
   #this is a very precarious attempt to minimally parse the blacklist, but it works.
   echo "$bl_line" | sed 's/::::/ /g'| sed 's/:::/ /g' | grep --color "\[technical\]\|\[nonfree\]\|\[semifree\]\|\[FIXME:description\]\|\[uses-nonfree\]\|\[use-nonfree\]\|\[branding\]\|\[recommends-nonfree\]\|\[trademark-issue\]"
   export GREP_COLOR='0'
}

function color_codes ()
{
   nonfree=$1; semifree=$2; technical=$3; fix_doc=$4; no_desc=$5
   echo -e "\n${white}Color codes:"
   ! [[ $nonfree == "0" ]] && echo -e "${red}Red:$nc Totally non-free/libre, closed source ${white}($nonfree)$nc."
   ! [[ $semifree == "0" ]] && echo -e "${yellow}Yellow:$nc Contains or depends on non-free/libre software ${white}($semifree)$nc."
   ! [[ $technical == "0" ]] && echo -e "${green}Green:$nc It IS by itself free/libre, but has some technical, branding or \
trademark issue, or simply points somehow to non-free/libre software ${white}($technical)$nc."
   ! [[ $fix_doc == "0" ]] && echo -e "${white}White:$nc Package description needs to be corrected ${white}($fix_doc).$nc"
   ! [[ $no_desc == "0" ]] && echo -e "${blue}Blue:$nc there is no description of this package in Parabola's blacklist ${white}($no_desc)$nc."
}

function help ()
{
   echo -e "\n${green}IsFree$nc (v1.2 - 2016) is fundamentally aimed to find out whether there are \
one or more non-free/libre Arch Linux software installed in your system. The tests are based upon \
Parabola's blacklists, which can be found in https://git.parabola.nu/blacklist.git/plain/blacklist.txt \
(blacklisted official Arch packages), https://git.parabola.nu/blacklist.git/plain/aur-blacklist.txt \
(AUR blacklisted packages), and https://git.parabola.nu/blacklist.git/plain/your-privacy-blacklist.txt \
(privacy risking packages)."
   echo -e "\n${white}Usage:$nc"
   echo -e "${yellow}./isfree.sh [package_name]$nc (inspect an individual package)"
   echo -e "${yellow}            -o | --official$nc (scan your system for non-free/libre official \
Arch packages)"
   echo -e "${yellow}            -a | --aur$nc (scan your system for non-free/libre AUR software)"   
   echo -e "${yellow}            -r | --repo [repo_name]$nc (inspect an official Arch Linux repo for \
non-free/libre packages)"
   echo -e "${yellow}            -p | --privacy$nc (scan the system for software that, according to \
Parabola, might be compromizing your privacy)"
   echo -e "${yellow}            -lo | --list-official$nc (list all the official Arch Linux \
non-free/libre packages)"
   echo -e "${yellow}            -la | --list-aur$nc (list all the AUR non-free/libre packages)"   
   echo -e "${yellow}            -lp | --list-privacy$nc (list all the privacy threatening software)"
   echo -e "${yellow}            -v | --version$nc (show program version)"
   echo -e "${yellow}            -h | --help$nc (show this help and exit)"
   echo -e "${cyan}Note:$nc In case you are interested in a 100% free/libre Linux you may want to take \
a look at Parabola GNU/Linux-libre's wiki (https://wiki.parabola.nu/Main_Page)\n"
#Here's GNU's explanation as to why Arch isn't entirely free, and thereby not endorsed by them:
#"Arch has the two usual problems: there's no clear policy about what software can be included, 
#and nonfree blobs are shipped with their kernel, Linux. Arch also has no policy about not 
#distributing nonfree software through their normal channels." (http://www.gnu.org/distros/common-distros.en.html)
#Now, the question is: which are these blobs exactly? And am I using them? Are they really 
#loaded by my kernel?

#The linux-libre kernel, just as the corresponding firmware and headers, could be found in the AUR
#As to the firmware issue, you can start by looking at the firmware needed (=loaded?) by your 
#kernel by running the following command:
# $ modinfo -F firmware `lsmod | tail -n +2 | cut -f 1 -d ' '`
#When running this command it shows a certain amount of firmware (=~10). Nonetheless, neither
#of them are listed by dmesg. So, are they really loaded by my kernel?  
# However, I still need to figure out which firmware is free/libre and which is not.
#This thread in the Arch forum sheds some light on this issue:
# https://bbs.archlinux.org/viewtopic.php?id=169661
}

###BODY####
if [[ $# -eq 0 ]]; then
   help
   exit 0
fi
case $1 in
   -o|--official) 
      get_blacklist
      echo -n "Getting installed official packages... "
      inst_packs=( $(pacman -Qn | grep -v parabola | awk '{print $1}') ) && echo -e "${green}Done$nc" && sleep 1
      echo -e "Non-free/libre packages installed in your system:${nc}\n" 
      counter=0; fix_doc=0; nonfree=0; semifree=0; technical=0; no_desc=0
      for (( i=0;i<${#inst_packs[@]};i++ )); do
         if [[ $(cat /tmp/parabola_bl.txt | grep ^"${inst_packs[$i]}":) ]]; then
            counter=$((counter+1))
            blacklist_line ${inst_packs[$i]} $counter
         fi
      done
      [[ $counter -eq 0 ]] && echo -e "${green}You're free from non-free/libre official Arch packages!\nRichard loves you!$nc" && exit 0
      color_codes $nonfree $semifree $technical $fix_doc $no_desc
      echo -e "\n-------------"
      echo -e "Total installed official packages: ${white}$(pacman -Qn | wc -l)$nc"
      echo -e "${cyan}Non-free/libre$nc found packages:     ${cyan}$counter$nc"
      echo -e "Free/libre official Arch packages: ${white}$(( (($(pacman -Q | wc -l)-counter)*100) / $(pacman -Q | wc -l) ))%$nc"
      rm /tmp/parabola_bl.txt
   ;;
   -a|--aur) 
      get_blacklist aur
      echo -n "Getting installed AUR packages... "
      aur_packs=( $(pacman -Qm | awk '{print $1}') ) && echo -e "${green}Done$nc" && sleep 1
      echo -e "Non-free/libre AUR packages installed in your system:${nc}\n" 
      counter=0; fix_doc=0; nonfree=0; semifree=0; technical=0; no_desc=0
      for (( i=0;i<${#aur_packs[@]};i++ )); do
         if [[ $(cat /tmp/parabola_bl.txt | grep ^"${aur_packs[$i]}":) ]]; then
            counter=$((counter+1))
            blacklist_line ${aur_packs[$i]} $counter
         fi
      done
      [[ $counter -eq 0 ]] && echo -e "${green}None! You're free from AUR non-free/libre packages!$nc" && exit 0
      color_codes $nonfree $semifree $technical $fix_doc $no_desc
      echo -e "\n-------------"
      echo -e "Total installed AUR packages:  ${white}$(pacman -Qm | wc -l)$nc"
      echo -e "${cyan}Non-free/libre$nc found packages: ${cyan}${counter}$nc"
      rm /tmp/parabola_bl.txt
   ;;
   -r|--repo)
      if [[ $2 == "" ]]; then
         echo "Repository not specified." 
         echo -e "Usage: ./isfree.sh -r [repo_name]\n" && exit 0
      fi
      case $2 in
         core);;
         extra);;
         community);;
         multilib)
            if ! [[ $(cat /etc/pacman.conf | grep ^"\[multilib\]") ]]; then
               echo -e "${red}Error:$nc 'multilib' repository is disabled.  You can enable it by editing /etc/pacman.conf" && exit 0
            fi
         ;;
         testing)
            if ! [[ $(cat /etc/pacman.conf | grep ^"\[testing\]") ]]; then
               echo -e "${red}Error:$nc 'testing' repository is disabled. You can enable it by editing /etc/pacman.conf" && exit 0
            fi
         ;;
         *) echo -e "${red}Error:$nc '${2}' repository doesn't exist." && exit 0;;
      esac
      repo=$2
      repo_packs=( $(pacman -Sl $repo | awk '{print $2}') )
      get_blacklist
      echo -e "Non-free/libre official Arch packages from ${white}$repo${nc} repository:${nc}\n"
      counter=0; fix_doc=0; nonfree=0; semifree=0; technical=0; no_desc=0
      for (( i=0;i<${#repo_packs[@]};i++ )); do
         if [[ $(cat /tmp/parabola_bl.txt | grep ^"${repo_packs[$i]}":) ]]; then
            counter=$((counter+1))
            blacklist_line ${repo_packs[$i]} $counter
         fi
      done
      [[ $counter -eq 0 ]] && echo -e "${green}$(echo $repo | tr '[:lower:]' '[:upper:]') is free from non-free/libre software!$nc" && exit 0
      color_codes $nonfree $semifree $technical $fix_doc $no_desc
      echo -e "\n-------------"
      echo -e "$white$(echo $repo | tr '[:lower:]' '[:upper:]')$nc: $counter/$(pacman -Sl $repo | wc -l) non-free/libre packages."
      rm /tmp/parabola_bl.txt
   ;;
   -p|--privacy) 
      get_blacklist privacy
      echo -n "Getting installed packages... "
      packs=( $(pacman -Q | awk '{print $1}') ) && echo -e "${green}Done$nc" && sleep 1
      echo -e "Non-secure packages installed in your system:${nc}\n" 
      counter=0; fix_doc=0; nonfree=0; semifree=0; technical=0; no_desc=0
      for (( i=0;i<${#packs[@]};i++ )); do
         if [[ $(cat /tmp/parabola_bl.txt | grep ^"${packs[$i]}":) ]]; then
            counter=$((counter+1))
            blacklist_line ${packs[$i]} $counter
         fi
      done
      [[ $counter -eq 0 ]] && echo -e "${green}None! You're free from privacy risking packages!$nc" && exit 0
      color_codes $nonfree $semifree $technical $fix_doc $no_desc
      echo -e "\n-------------"
      echo -e "${white}${counter}/$(pacman -Q | wc -l)$nc packages might be compromizing your privacy."
      rm /tmp/parabola_bl.txt
   ;;   
   -h|--help) help;;
   -lo|--list-official) 
      get_blacklist
      counter=0
      echo -e "Non-free/libre Arch official packages:\n" && sleep 1.5
      for (( i=0;i<${#blacklist[@]};i++ )); do
         echo "$((i+1)) - $(echo ${blacklist[$i]} | sed 's/#//g' | cut -d":" -f1)"
         counter=$((counter+1))
      done
      rm /tmp/parabola_bl.txt
   ;;
   -la|--list-aur) 
      get_blacklist aur
      counter=0
      echo -e "Non-free/libre AUR packages:\n" && sleep 1.5
      for (( i=0;i<${#blacklist[@]};i++ )); do
         echo "$((i+1)) - $(echo ${blacklist[$i]} | sed 's/#//g' | cut -d":" -f1)"
         counter=$((counter+1))
      done
      rm /tmp/parabola_bl.txt
   ;;
   -lp|--list-privacy) 
     get_blacklist privacy
     counter=0
     echo -e "Privacy threatening software:\n" && sleep 1.5
     for (( i=0;i<${#blacklist[@]};i++ )); do
        echo "$((i+1)) - $(echo ${blacklist[$i]} | sed 's/#//g' | cut -d":" -f1)"
        counter=$((counter+1))
     done
     rm /tmp/parabola_bl.txt
   ;;   
   -v|--version) 
      echo "IsFree version: 1.2 (Aug 29, 2016)"
      echo "v1.1: AUR packages support was added."
      echo "v1.2: An option was added to inspect the system for privacy threatening software, and another one to list all the threating packs according to Parabola."
      echo -e "By L. M. Abramovich\n"
   ;;
   
   #####Check an individual package####
   -*|--*) echo -e "${red}Error:$nc $1 is not a valid argument. Type ./isfree.sh -h for help." && exit 0;;
   *)
      pack=$1
      pack="$(echo $pack | tr '[:upper:]' '[:lower:]')"
      if ! [[ $(pacman -Ss ^${pack}) ]]; then
         echo -e "${red}Error:$nc $pack is not an official Arch Linux package." 
         exit 0
      fi
      get_blacklist
      if [[ $(cat /tmp/parabola_bl.txt | grep ^"${pack}":) ]]; then
         echo -ne "${red}$pack is a non-free/libre package: $nc"
         cat /tmp/parabola_bl.txt | grep ^${pack}:
      else
         echo -e "${green}$pack is a free/libre package!$nc"
      fi
      rm /tmp/parabola_bl.txt
      exit 0
   ;;
esac
