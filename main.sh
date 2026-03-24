#!/bin/bash
source ./db_operations


clear
echo "=========================================="
echo "      DATABASE MANAGEMENT SYSTEM          "
echo "=========================================="

PS3="Enter Your choice: "


select choice in "Create Database" "List Databases" "Connect To Database" "Drop Database" "Exit"
	do
		case $REPLY in
			1) create_db ;;
			2) list_db ;;
 			3) connect_db ;;
 			4) drop_db ;;
 			5) echo  "exited" 
				 break ;;
			*) echo " $REPLY is not an option "			 
		esac
		
	done


