#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati

# Colors
nc="\e[0m"
bold="\e[1m"
underline="\e[4m"
bold_red="\e[1;31m"
bold_green="\e[1;32m"
bold_yellow="\e[1;33m"

# Banner
show_banner() {
clear
echo -e "${bold_green}"
cat << "EOF"
 ⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀
 ⢠⠊⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠏⡄
 ⠈⡐⠡⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⠀⠀⡘⠄⠃
 ⠀⠐⣧⡐⢄⣴⠾⡟⠛⠛⢻⡳⣦⡀⠊⣜⠎⠀
 ⠀⠀⠘⣧⢆⡯⠀⠀⠀⠀⠀⠀⢜⡠⣹⠏⠀⠀  _  __
 ⠀⠀⢘⡙⡞⡇⠀⠀⠀⠀⠀⠀⢀⠑⠏⣵⠀  | |/ /   __ _    __ _    ___
 ⠀⠀⢰⡓⡄⠃⠀⢀⠀⠀⡀⠀⠈⢢⠇⡆⠀⠀ | ' /   / _` |  / _` |  / _ \
 ⠀⠀⠈⢰⠘⢍⣉⡹⡆⠀⣯⣉⡉⠅⡎⡇⠀⠀ | . \  | (_| | | (_| | |  __/
 ⠀⠀⠈⡎⠣⠤⢒⠂⠀⠀⠁⣲⡤⠔⢱⠁⠀⠀ |_|\_\  \__,_|  \__, |  \___|
 ⠀⠀⠀⠑⣔⡴⣆⡝⠤⠤⢪⣵⣇⢢⠞⠀⠀⠀                 |___/
 ⠀⠀⠀⠀⠈⢻⢿⡘⣓⣒⠏⡿⡿⠁⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⠀⢏⠚⠋⠉⠛⣱⠁⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠉⠁⠀⠉⠁⠀⠀⠀⠀⠀⠀
EOF
echo -e "${nc}"
echo -e "${bold_green}Kage${nc} — This script generates a targeted password wordlist based on user-provided intel.\n"
echo -e " Author: Haitham Aouati"
echo -e " GitHub: ${underline}github.com/haithamaouati${nc}\n"
}

# Help
show_help() {
cat << EOF
Usage: ./kage.sh

This script generates a targeted password wordlist based on user-provided intel.

Prompts include:
 - Name, birthdates, pets, kids, partner, company
 - Optional keywords
 - Toggles for leetspeak, capitalization, numeric suffixes, separators

EOF
exit 0
}

[[ "$1" == "--help" ]] && show_help
show_banner

#==========[ Input Section ]==========#
read -p "- First Name: " first_name
read -p "- Surname: " surname
read -p "- Nickname: " nickname
read -p "- Birthdate (DDMMYYYY): " birthdate

read -p "- Partner's Name: " partner_name
read -p "- Partner's Nickname: " partner_nickname
read -p "- Partner's Birthdate (DDMMYYYY): " partner_birthdate

read -p "- Child's Name: " child_name
read -p "- Child's Nickname: " child_nickname
read -p "- Child's Birthdate (DDMMYYYY): " child_birthdate

read -p "- Pet's Name: " pet_name
read -p "- Company Name: " company
read -p "- Hobby: " hobby

all_inputs=(
  "$first_name" "$surname" "$nickname" "$birthdate"
  "$partner_name" "$partner_nickname" "$partner_birthdate"
  "$child_name" "$child_nickname" "$child_birthdate"
  "$pet_name" "$company" "$hobby"
)

all_empty=true
for input in "${all_inputs[@]}"; do
  if [[ -n "$input" ]]; then
    all_empty=false
    break
  fi
done

if [[ "$all_empty" == true ]]; then
  echo -e "\n${bold_red}[!]${nc} No input provided. Can't generate meaningful wordlist.\n"
  exit 1
fi

# Y/N helper
yes_no_default_no() {
    local prompt="$1"
    read -p "$prompt (Y/N): " reply
    [[ "$reply" =~ ^[Yy]$ ]] && return 0 || return 1
}

# Keywords
keywords=()
if yes_no_default_no "Do you want to add some keywords about the target?"; then
    read -p "Enter keywords (comma-separated): " raw_keywords
    IFS=',' read -ra keywords <<< "\$raw_keywords"
    for i in "\${!keywords[@]}"; do
        keywords[$i]="\${keywords[$i]// /}"
    done
fi

# Toggles
use_space=no
use_specials=no
use_leetspeak=no
use_case=no
use_suffix=no

yes_no_default_no "Leave space between combined words?" && use_space=yes
yes_no_default_no "Use special characters between combined words?" && use_specials=yes
yes_no_default_no "Enable Leetspeak variants?" && use_leetspeak=yes
yes_no_default_no "Enable Capitalization variants?" && use_case=yes
yes_no_default_no "Append numeric suffixes?" && use_suffix=yes

min_len=6
max_len=20

#==========[ Functions ]==========#
leetify() {
    echo "$1" | sed -e 's/a/@/gi' -e 's/e/3/gi' -e 's/i/1/gi' -e 's/o/0/gi' -e 's/s/\$/gi' -e 's/t/7/gi'
}

case_variants() {
    local word="$1"
    local result=("$word")
    [[ "$use_case" == yes ]] && result+=("${word^^}" "${word,,}" "${word^}")
    echo "${result[@]}"
}

slice_date_parts() {
    local date="$1"
    [[ -z "$date" ]] && return
    echo "$date"
    echo "${date:0:2}" "${date:2:2}" "${date:4:4}" "${date:4:2}" "${date:2:6}" "${date:0:4}"
}

suffix_generator() {
    local base="$1"
    echo "$base" "$base"1 "$base"123 "$base"2024 "$base"@ "$base"! "$base"11 "$base"01 "$base"#1 "$base"99
}

generate_combinations() {
    local raw_inputs=(
        "$first_name" "$surname" "$nickname"
        "$partner_name" "$partner_nickname"
        "$child_name" "$child_nickname"
        "$pet_name" "$company" "$hobby"
        "${keywords[@]}"
    )

    for d in "$birthdate" "$partner_birthdate" "$child_birthdate"; do
        for dp in $(slice_date_parts "$d"); do
            raw_inputs+=("$dp")
        done
    done

    expanded=()
    for word in "${raw_inputs[@]}"; do
        [[ -z "$word" ]] && continue
        for variant in $(case_variants "$word"); do
            expanded+=("$variant")
            [[ "$use_leetspeak" == yes ]] && expanded+=("$(leetify "$variant")")
        done
    done

    results=()
    for e in "${expanded[@]}"; do
        results+=("$e")
        [[ "$use_suffix" == yes ]] && while read -r s; do results+=("$s"); done < <(suffix_generator "$e")
    done

    separators=("")
    [[ "$use_space" == yes ]] && separators+=(" ")
    [[ "$use_specials" == yes ]] && separators+=("_" "-" "." "@" "#" "!")

    for i in "${expanded[@]}"; do
        for j in "${expanded[@]}"; do
            [[ "$i" == "$j" ]] && continue
            for sep in "${separators[@]}"; do
                combo="$i$sep$j"
                [[ "$use_suffix" == yes ]] && while read -r s; do results+=("$s"); done < <(suffix_generator "$combo")
                results+=("$combo")
            done
        done
    done

    for i in "${expanded[@]}"; do
        for j in "${expanded[@]}"; do
            for k in "${expanded[@]}"; do
                [[ "$i" == "$j" || "$j" == "$k" || "$i" == "$k" ]] && continue
                for sep1 in "${separators[@]}"; do
                    for sep2 in "${separators[@]}"; do
                        combo="$i$sep1$j$sep2$k"
                        [[ "$use_suffix" == yes ]] && while read -r s; do results+=("$s"); done < <(suffix_generator "$combo")
                        results+=("$combo")
                    done
                done
            done
        done
    done

    filtered=()
    for item in "${results[@]}"; do
        len=${#item}
        if (( len >= min_len && len <= max_len )); then
            filtered+=("$item")
        fi
    done

    echo -e "\n${bold_green}[*]${nc} Generated ${bold_yellow}${#filtered[@]}${nc} candidate passwords.\n"

    if yes_no_default_no "Save to 'wordlist.txt'?"; then
        printf "%s\n" "${filtered[@]}" | sort -u > wordlist.txt
        echo -e "\n${bold_green}[+]${nc} Saved ${bold_green}$(wc -l < wordlist.txt)${nc} unique passwords to ${bold_green}wordlist.txt${nc}\n"
    else
        echo -e "\n${bold_red}[-]${nc} Wordlist not saved.\n"
    fi
}

#==========[ Run It ]==========#
generate_combinations
