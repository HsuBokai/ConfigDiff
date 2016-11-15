#!/bin/bash

#set -x

[ $# -lt 1 ] && echo "Usage: $0 <config.sh>" && exit -1
source $1

function check {
	[ $# -lt 2 ] && echo "Usage: $0  <error>  <line_number>" && exit -1

	local error=$1
	shift
	local line_number=$1

	[ $error -ne 0 ] && echo "($line_number) error !!" && exit -1
}

function append_text {
	[ $# -lt 4 ] && echo "Usage: $0  <edit_file>  <27>  <in_fil>  <30,33>" && exit -1

	local edit_file=$1
	shift
	local line=$1
	shift
	local in_file=$1
	shift
	local range=$1

	local add_text=/tmp/add_text
	local temp_file=/tmp/temp_file

	sed -n $range'p' $in_file > $add_text
	check $? $LINENO

	if [ 0 == $line ]; then
		cat $add_text $edit_file > $temp_file
		check $? $LINENO

		mv $temp_file $edit_file
		check $? $LINENO
	else
		sed -i  $line'r '$add_text $edit_file
		check $? $LINENO
	fi

	return 0
}

configs=/tmp/configs

awk -f show_config.awk $ref_config > $configs
check $? $LINENO

while IFS='' read -r line || [[ -n "$line" ]]; do
	IFS=' ' read line_number config <<< $line
	grep_result=$(grep -n $config'=' $edit_config | awk 'BEGIN{FS=":"}{print $1; exit 0;}')
	if [ $grep_result ]; then
		append_text $edit_config $grep_result $ref_config $line_number
		sed -i  $grep_result'd' $edit_config
		check $? $LINENO
	else
		grep_result=$(grep -n $config' is not set' $edit_config | awk 'BEGIN{FS=":"}{print $1; exit 0;}')
		if [ $grep_result ]; then
			append_text $edit_config $grep_result $ref_config $line_number
			sed -i  $grep_result'd' $edit_config
			check $? $LINENO
		else
			sed -n  $line_number'p' $ref_config >> $edit_config
		fi
	fi
done < $configs

exit 0;
