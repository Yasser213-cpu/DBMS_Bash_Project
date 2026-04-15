#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'


function create_table {
    local db=$1
    local old_ps3="$PS3"
    read -p "Enter the table name to create:  " tbl_name

    if [ -z "$tbl_name" ] ; then
        echo -e "${RED}${BOLD}Error:Table name can't be empty${NC} ❌"
    elif [[ -f "DBMS/$db/$tbl_name.meta" ]] ; then
        echo -e "${RED}${BOLD}Error: $tbl_name is already existed${NC} ❌"
    elif [[ ! $tbl_name =~ ^[a-zA-Z] ]]; then
        echo -e "${RED}${BOLD}Error: Name must start only with letters${NC} ❌"
    elif [[ $tbl_name == *" "* ]]; then
        echo -e "${RED}${BOLD}Error: table name is only 1 word you can use (-,_,$,...)${NC} ❌"
    else
        typeset -i num_col
		while true
		do
        	read -p "Enter number of columns you wanted: " num_col
			if [[ $num_col -eq 0 ]] ; then
            	echo -e "${RED}${BOLD}You must enter a number greater than 0 !! ${NC}"
        	else
				break
			fi
		done

        
            cols_names=""
            cols_types=""
            col_pk=""

            for (( i=1; i<=$num_col; i++ )); do
                read -p "enter name for column $i: " col_name

                if [ -z "$col_name" ] ; then
                    echo -e "${RED}${BOLD}Error:Column name can't be empty${NC} ❌"
                    i=$i-1
                elif [[ ":$cols_names:" == *":$col_name:"*  ]] ; then
                    echo -e "${RED}${BOLD}Error: $col_name is already existed${NC} ❌"
                    i=$i-1
                elif [[ ! $col_name =~ ^[a-zA-Z] ]]; then
                    echo -e "${RED}${BOLD}Error: Name must start only with letters${NC} ❌"
                    i=$i-1
                elif [[ $col_name == *" "* ]]; then
                    echo -e "${RED}${BOLD}Error: Column name is only 1 word you can use (-,_,$,...)${NC} ❌"
                    i=$i-1
                else
                    PS3="Choose type for $col_name: "

                    select type in "int" "string"
                    do
                        case $type in
                            int|string)
                                col_type=$type
                                break
                                ;;
                            *)
                                echo -e "${RED}${BOLD}Invalid option!${NC}"
                                ;;
                        esac
                    done

                    if [ -z "$col_pk" ] ; then
                        read -p "Do you want $col_name a primary key? (yes/No) : " is_pk
                        if [[ "$is_pk" =~ ^[yY] ]] ; then
                            col_pk=$col_name
			    echo -e "${GREEN}${BOLD}Column $col_name is the Primary key${NC} ✅"
                        fi
                    fi

                    if [[ $i -eq $num_col ]]; then
                        cols_names+=$col_name
                        cols_types+=$col_type
                    else
                        cols_names+="$col_name:"
                        cols_types+="$col_type:"
                    fi
                fi
            done
	   if [ -z "$col_pk" ]; then
		col_pk=$(echo "$cols_names" | cut -d':' -f1)
		echo -e "${YELLOW}${BOLD}Note: No PK selected. [$col_pk] is set as default PK.${NC}"
           fi
            echo "$cols_names" > "DBMS/$db/$tbl_name.meta"
            echo "$cols_types" >> "DBMS/$db/$tbl_name.meta"
            echo "PK:$col_pk" >> "DBMS/$db/$tbl_name.meta"
	    touch "DBMS/$db/$tbl_name.data"

            echo -e "${GREEN}${BOLD}Table has been created successfully${NC} ✅"
        
    fi
            PS3="$old_ps3"

}


function insert_into {
	local db=$1
	read -p "Enter table name to insert into: " tbl_name
	while true
	do
		if [ ! -f "DBMS/$db/$tbl_name.meta" ]
		then
			echo -e "${RED}${BOLD}Table doesn't exist!!${NC} ❌"
			echo " "
			read -p "Enter table name: " tbl_name
		else 
			break
		fi 	
	done
	record=""
	col_names_arr=($(awk -F: 'NR==1 {for(i=1;i<=NF;i++) print $i}' "DBMS/$db/$tbl_name.meta"))
	col_types_arr=($(awk -F: 'NR==2 {for(i=1;i<=NF;i++) print $i}' "DBMS/$db/$tbl_name.meta"))
	pk=$(awk -F: 'NR==3 {print $2}' "DBMS/$db/$tbl_name.meta")
	#pk_index=$(awk -F: -v primary="$pk" ' NR==1 { for(i=1;i<=NF;i++) if($i==primary) print i }' "DBMS/$db/$tbl_name.meta")
	pk_index=-1 
	for i in "${!col_names_arr[@]}"
		 do
   			if [[ "${col_names_arr[$i]}" == "$pk" ]]; then
       			pk_index=$((i + 1)) 
       			break
   			fi
		done
	col_num=${#col_names_arr[@]}
	for((j=0;j<$col_num;j++))
	do
		read -p "Enter column ${col_names_arr[$j]} (${col_types_arr[$j]}): " val
		
		if [ -z "$val" ]
		then
			echo -e "${RED}${BOLD}Value cannot be empty!!${NC}"
			((--j))
			continue
		elif [[ "${col_types_arr[$j]}" == "int" ]] && [[ ! "$val" =~ ^[0-9]+$ ]]
		then
			echo -e "${RED}${BOLD}You must enter an integer value${NC}"
			((--j))
			continue
		elif [[ "${col_types_arr[$j]}" == "string" ]] && [[ ! "$val" =~ ^[A-Za-z0-9]+$ ]]
		then
			echo -e "${RED}${BOLD}You must enter a string value and without spaces.${NC}"
			((--j))
			continue
		elif [[ "${col_names_arr[$j]}" == "$pk"  ]]
		then
			check=$(awk -F: -v col="$pk_index" -v new_val="$val" '$col == new_val {print $0}' "DBMS/$db/$tbl_name.data")
			if [ ! -z "$check" ]
			then
			echo -e "${RED}${BOLD}Primary key cannot be duplicated!!${NC}"
			((--j))
			continue
			fi	
		fi
		record+="$val"
		if [ $j -lt $((col_num-1)) ]
		then
    			record+=":"
		fi
	done

	echo "$record" >> "DBMS/$db/$tbl_name.data"
	echo -e "${GREEN}${BOLD}Record inserted successfully.${NC} ✅"

}

function list_tables {
	local db=$1
	echo "-------------------------------"
	echo "--- Tables in Database: $db ---"
	echo "-------------------------------"
	if [ -z "$(ls "DBMS/$db")" ]; then
		echo -e  "${GREEN}${BOLD}No tables Found in this DB. ${NC}"
	else
		ls "DBMS/$db" | grep ".data$" | cut -d '.' -f1 
	fi
	echo "-------------------------------"
}

function drop_table {
	local db=$1
	read -p "enter the table name you want to drop: " tbl_name
	if [ -z "$tbl_name" ] ; then
        	echo -e "${RED}${BOLD}Error: Table name can't be empty!${NC} ❌"

	elif [[ ! -f "DBMS/$db/$tbl_name.meta" ]] ; then
		echo -e "${RED}${BOLD}Error: Table '$tbl_name' does not exist!${NC} ❌"
	else
		read -p "Are you sure you want to delete '$tbl_name'? (y/n) " confirm
		if [[ "$confirm" =~ ^[yY] ]]; then
			rm -r "DBMS/$db/$tbl_name.meta"
			rm -r "DBMS/$db/$tbl_name.data"
			echo -e "${GREEN}${BOLD}Table has been dropped successfully.${NC} ✅"
		else
			echo -e "${GREEN}${BOLD}Drop operation canceled.${NC} 😌"
		fi
	fi

}

	
function select_table {
	local db=$1
	
	
	while true
	do
		read -p "Enter table name: " tbl_name
		if [ ! -f "DBMS/$db/$tbl_name.meta" ]
		then 
		echo -e "${RED}${BOLD}Table $tbl_name doesn't exist!!${NC} ❌"
		else 
			break
		fi
	done

	echo "----------------------------"
	echo "1) Select All"
	echo "2) Select by a specific column"
	echo "----------------------------"
	  
	read -p "Select an option: " select_op
	
	case $select_op in
	1) 	echo "====================================================="
		echo "----------- All values of table $tbl_name -----------"
	 	echo "====================================================="
		{ head -1 "DBMS/$db/$tbl_name.meta"; cat "DBMS/$db/$tbl_name.data"; } | column -t -s ":"
		echo "======================================================"
		  ;;
	2) 	
		echo "---------------------"
		echo "- Available columns -"
		echo "---------------------"
		head -1 "DBMS/$db/$tbl_name.meta" | tr ":" " : "
		echo " "
		echo "------------------------------------------"
		while true
		do						
			read -p "Enter column name to be filterd with: " col_name
			col_index=$(awk -F: -v cn="$col_name" ' NR==1 { for(i=1;i<=NF;i++) if(cn==$i) print i }' "DBMS/$db/$tbl_name.meta")
			if [ -z "$col_index" ]
			then
				echo -e "${RED}${BOLD}Column doesn't exist!!${NC} ❌"
			else
				break
			fi
		done
		read -p "Enter value of column $col_name to serach with: " search_val
		echo "======================================================"
		echo "------------------- Search Results -------------------"
		echo "======================================================"
		{
		head -1 "DBMS/$db/$tbl_name.meta"
		awk -F: -v ci="$col_index" -v sv="$search_val" '$ci == sv {print $0}' "DBMS/$db/$tbl_name.data"
		} | column -t -s ":"
		echo "======================================================"
		;;
	*) echo -e "${RED}${BOLD}Invalid option!${NC}" ;; 
	esac
	
}	


function update_table {
	db=$1
	while true
        do
                read -p "Enter table name: " tbl_name
                if [ ! -f "DBMS/$db/$tbl_name.meta" ]
                then 
                echo -e "${RED}${BOLD}Table $tbl_name doesn't exist!!${NC} ❌"
                else 
                        break
                fi
        done

	        echo "---------------------"
                echo "- Available columns -"
		echo "---------------------"
                head -1 "DBMS/$db/$tbl_name.meta" | tr ":" " : "
                echo "------------------------------------------"
                while true
                do
                        read -p "Enter the column name to use for locating the record (WHERE): " col_name
                        col_index=$(awk -F: -v cn="$col_name" ' NR==1 { for(i=1;i<=NF;i++) if(cn==$i) print i }' "DBMS/$db/$tbl_name.meta")
                        if [ -z "$col_index" ]
                        then
                                echo -e "${RED}${BOLD}Column doesn't exist!!${NC} ❌"
                        else
                                break
                        fi
                done
                read -p "Enter the value of [$col_name] for the record you want to update: " search_val
		where_check=$(awk -F: -v ci="$col_index" -v val="$search_val" '$ci == val { print $0 }'  "DBMS/$db/$tbl_name.data")
		if [ ! -z "$where_check" ]
		then

		while true
                do
                        read -p "Enter the column name to be updated: " col_update
                        col_index_update=$(awk -F: -v cn="$col_update" ' NR==1 { for(i=1;i<=NF;i++) if(cn==$i) print i }' "DBMS/$db/$tbl_name.meta")
                        if [ -z "$col_index_update" ]
                        then
                                echo -e "${RED}${BOLD}Column doesn't exist!!${NC} ❌"
                        else
                                break
                        fi
                done
		pk=$(awk -F: ' NR==3 {print $2}' "DBMS/$db/$tbl_name.meta")
		pk_index=$(awk -F: -v primary="$pk" ' NR==1 { for(i=1;i<=NF;i++) if($i==primary) print i }' "DBMS/$db/$tbl_name.meta")
		col_upated_datatype=$(awk -F: -v ci="$col_index_update"  ' NR==2 {print $ci}' "DBMS/$db/$tbl_name.meta")

		while true
		do
			read -p "Enter the new value of [$col_update]: " new_val
			check=$(awk -F: -v col="$pk_index" -v val="$new_val" '$col == val {print $0}' "DBMS/$db/$tbl_name.data")
			if [ -z "$new_val" ]
			then
				echo -e "${RED}${BOLD}Value cann't be empty!!${NC} ❌"
			elif [[ "$col_upated_datatype" == "int" ]] && [[ ! "$new_val" =~ ^[0-9]+$ ]]
                	then
                        	echo -e "${RED}${BOLD}You must enter an integer value${NC}"
                	elif [[ "$col_upated_datatype" == "string" ]] && [[ ! "$new_val" =~ ^[A-Za-z0-9]+$ ]]
                	then
                        	echo -e "${RED}${BOLD}You must enter a string value${NC}"
			elif [[ "$col_update" == "$pk"  ]] && [ ! -z "$check" ]
                	then             	
                        	echo -e "${RED}${BOLD}Primary key cannot be duplicated!!${NC} ❌"
                        
			else
				break
                	fi
		done	
	awk -F: -v ci_w="$col_index" -v val_w="$search_val" -v cu="$col_index_update" -v new_val="$new_val" 'BEGIN{OFS=":"} { if ( $ci_w == val_w ) $cu = new_val; print $0 }' "DBMS/$db/$tbl_name.data" > "DBMS/$db/$tbl_name.tmp" && mv "DBMS/$db/$tbl_name.tmp" "DBMS/$db/$tbl_name.data"
	echo -e "${GREEN}${BOLD}Update has been done successfully${NC} ✅"
	echo "============================================================" 
		
		else 
			echo -e "${RED}${BOLD}There are no records match this condition [$col_name]=[$search_val] !!${NC}"
		fi

}



function delete_from_table {
    db=$1
    while true; do
        read -p "Enter table name: " tbl_name
        if [ ! -f "DBMS/$db/$tbl_name.meta" ]; then
            echo -e "${RED}${BOLD}Table $tbl_name does not exist!!${NC}"
        else
            break
        fi
    done
    echo "-----------------------------------"
    echo "1) delete all from table (truncate)"
    echo "2) delete using where"
    echo "-----------------------------------"
    read -p "Choose an option: " op
    case "$op" in 
	1) echo -e "${BOLD}⚠️ WARNING: You are about to delete the whole table $tbl_name ${NC}"
  	read -p "Are you sure? (y/n): " confirm
	if [[ "$confirm" =~ ^[Yy]$ ]]; then
		> "DBMS/$db/$tbl_name.data"
        	echo "------------------------------------------"
		echo -e "${GREEN}${BOLD}All records deleted successfully.${NC} ✅ "
        	echo -e "${BOLD}Table [$tbl_name] is now empty.${NC}"
        	echo "------------------------------------------"
	else
		echo -e "${RED}${BOLD}Operation Cancelled.${NC} ❌"
	fi 
	;;

	2)
    echo "---------------------"
    echo "- Available columns -"
    echo "---------------------"
    head -1 "DBMS/$db/$tbl_name.meta" | tr ":" " : "
    echo "------------------------------------------"

    while true; do
	
	read -p "enter the column name to use for locating the record (WHERE): " col_name

	col_index=$(awk -F: -v cn="$col_name" 'NR==1 {for(i=1;i<=NF;i++) if (cn==$i) print i}' "DBMS/$db/$tbl_name.meta")
	if [ -z "$col_index" ]; then
		echo -e "${RED}${BOLD}Column doesn't exist!!${NC}"
	else
		break
	fi
   done
   read -p "Enter the value of [$col_name] to delete the record: " search_val
   where_check=$(awk -F: -v ci="$col_index" -v val="$search_val" '$ci == val { print $0 }'  "DBMS/$db/$tbl_name.data")
   if [ ! -z "$where_check" ] 
   then
   echo -e "${BOLD}⚠️ WARNING: You are about to delete records where [$col_name] is [$search_val].${NC}"
   read -p "Are you sure? (y/n): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        
        awk -F: -v ci="$col_index" -v sv="$search_val" '$ci != sv {print $0}' "DBMS/$db/$tbl_name.data" > "DBMS/$db/$tbl_name.tmp" && mv "DBMS/$db/$tbl_name.tmp" "DBMS/$db/$tbl_name.data"
        echo "------------------------------------------"
        echo -e "${GREEN}${BOLD}Deletion completed successfully.${NC} ✅"
        echo "------------------------------------------"
    else
        echo -e "${RED}${BOLD}Operation Cancelled.${NC} ❌"
    fi
    # ---------------------------------- 
  else
	echo -e "${RED}${BOLD}There is no record matching your input.${NC}"
	echo " "
  fi
;;
*) echo -e "${RED}${BOLLD}Invalid option!${NC}"
esac  
}
	
	
