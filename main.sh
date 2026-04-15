#!/bin/bash
source ./tbl_operations.sh
source ./db_operations.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e  "${BLUE}==========================================${NC}"
echo -e "${BOLD}      DATABASE MANAGEMENT SYSTEM         ${NC} "
echo -e "${BLUE}==========================================${NC}"
echo ""
while true
do
    echo ""
    echo -e "${RED}${BOLD}Main Menu:${NC}"
    echo -e "${RED}${BOLD}-----------${NC}"
    echo "1) Create Database"
    echo "2) List Databases"
    echo "3) Connect To Database"
    echo "4) Drop Database"
    echo "5) Exit"
    
    read -p "Enter Your choice: " REPLY

    case $REPLY in
        1) create_db ;;
        2) list_db ;;
        3) connect_db ;;
        4) drop_db ;;
        5) echo -e "${GREEN}Exited from Program${NC} ✅"
           break ;;
        *) echo " "
	   echo -e "${RED}${BOLD}[$REPLY] is not an option${NC} ❌ " ;;
    esac
done










#PS3="Enter Your choice: "
#select choice in "Create Database" "List Databases" "Connect To Database" "Drop Database" "Exit"
#	do
#		case $REPLY in
#			1) create_db ;;
#			2) list_db ;;
# 			3) connect_db ;;
# 			4) drop_db ;;
# 			5) echo  "exited" 
#				 break ;;
#			*) echo " $REPLY is not an option "			 
#		esac
#		
#	done


