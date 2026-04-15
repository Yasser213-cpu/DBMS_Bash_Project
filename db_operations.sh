#!/bin/bash


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'



create_db()  {
read -p "Enter DataBase Name: " db_name
if [ -z "$db_name" ] ; then
echo -e "${RED}${BOLD}Error:Database name can't be empty${NC} ❌"
elif [[ ! $db_name =~ ^[a-zA-Z] ]]; then
echo -e "${RED}${BOLD}Error: Name must start only with letters ❌"
elif [[ $db_name == *" "* ]]; then
echo -e "${RED}${BOLD}Error: Database name is only 1 word you can use (-,_,$,...) ❌"
elif [ -d DBMS/$db_name ]; then
echo -e "${RED}${BOLD}Error: Database $db_name exists${NC} ❌"
else
mkdir -p DBMS/$db_name
echo -e "${GREEN}${BOLD}Database has been created successfully${NC} ✅ "
fi
}


function list_db {
if [ -z "$(ls -A  DBMS)" ] 
then 
	echo -e "${BOLD}There is no databases yet ${NC}" 
else 
	echo " "
	echo -e "${CYAN}==============================${NC}"
	echo -e "${CYAN}  DataBases in the system: ${NC}"
	echo -e "${CYAN}==============================${NC}"
	echo " "
	ls -A DBMS
	echo "----------------------------------------------"
fi

}

function connect_db {
#local old_ps3="$PS3"
read -p "Enter DataBase name to connect: " db_name
if [[ -z "$db_name"  ]]
then
	echo -e "${RED}${BOLD}DataBase name cannot be empty! ${NC}" 
elif [[ ! -d "DBMS/$db_name" ]]
then 
	echo -e "${RED}${BOLD}DataBase doesn't exist!!${NC}"
else 
	echo -e "${GREEN}${BOLD}Connected to $db_name successfully${NC} ✅"
	echo " "
	while true
	do	echo -e "${BOLD}Sub Menu${NC}"
		echo "=================="
    		echo "1) Create Table"
   		echo "2) List Tables"
    		echo "3) Drop Table"
    		echo "4) Insert into Table"
    		echo "5) Select from Table"
    		echo "6) Delete from Table"
    		echo "7) Update Table"
    		echo "8) Back to main menu"

    		read -p "Choose an operation on table: " REPLY

    		case $REPLY in
        		1) create_table "$db_name" ;;
        		2) list_tables "$db_name" ;;
        		3) drop_table "$db_name" ;;
        		4) insert_into "$db_name" ;;
        		5) select_table "$db_name" ;;
        		6) delete_from_table "$db_name" ;;
        		7) update_table "$db_name" ;;
        		8) echo "Back to Main Menu"
           			break ;;
        		*) echo -e "${RED}${BOLD}Invalid option, Try again !!${NC}" ;;
    		esac
	done
fi


}

function drop_db {
read -p "Enter DataBase name to be dropped: " db_name
if [[ -z "$db_name"  ]]
then
        echo -e "${RED}${BOLD}DataBase name cannot be empty! ${NC}"
elif [[ ! -d "DBMS/$db_name" ]]
then 
        echo -e "${RED}${BOLD}Error: DataBase not exists!! ${NC}"
else 
	read -p "⚠️  Are you sure to drop $db_name? (Y\N): " confirm
	if [[ "$confirm" =~ ^[Yy] ]]
	then
		rm -r "DBMS/$db_name"
		echo " "
		echo -e "${GREEN}${BOLD}DataBase $db_name dropped successfully${NC} ✅"
	else
		echo " "
		echo -e "${GREEN}${BOLD}Drop Cancelled! ${NC}"
	fi

fi

}
