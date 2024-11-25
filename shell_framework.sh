#!/bin/bash

# set -x

TotalStartTime=$(date +%s.%N)
OriginalPath=$(pwd)

RunFolder="$( cd "$(dirname "$0")" ; pwd -P )"
Name=$(basename $0)

cd $RunFolder

RootFolder=$(pwd)
FullPath=$RootFolder/$Name

LogFolder=$RootFolder/../log
[[ -d $LogFolder ]] || mkdir -p $LogFolder
LogFile=$LogFolder/$Name.log
PIDFile=$RootFolder/$Name.pid
ARCHIEVE_SIZE=2097152

#--------------------------------------------------------------------------------------------------
# Begin Logging Section

log() {
	local log_text="$1"
	local log_level="$2"
	local log_color="$3"

	# Default level to "info"
	[[ -z ${log_level} ]] && log_level="INFO " && log_color='\033[1;37m';
	echo -e "$(date +"%Y-%m-%d %H:%M:%S") $(hostname -s) ${log_level} [$Name] ($USER:$$) ${log_text}" >> $LogFile;
	echo -e "$(date +"%Y-%m-%d %H:%M:%S") $log_color${log_level}\033[0m ${log_text}";
	return 0;
}

house_keep_logfile() {
	#logfile_size=$(stat --printf="%s" $LogFile)
	logfile_size=$(stat -c "%s" $LogFile)
	
	TRACE "Log file=$LogFile size=$logfile_size"
	if [ $logfile_size -gt $ARCHIEVE_SIZE ]; then
		target_archieve_file=${LogFile}.$(date +%Y-%m-%d.%H%M%S)
		INFO "Archive $LogFile to ${target_archieve_file}.gz"
		mv $LogFile $target_archieve_file && > $LogFile && gzip $target_archieve_file
	fi
}

INFO()  { log "$1" "INFO " '\033[1;37m'; }
FATAL() { log "$1" "FATAL" '\033[1;35m'; exit 1 ; }
ERROR() { log "$1" "ERROR" '\033[1;31m'; }
WARN()  { log "$1" "WARN " '\033[1;33m'; }
DEBUG() { log "$1" "DEBUG" '\033[1;34m'; }
TRACE() { log "$1" "TRACE" '\033[1;36m'; }
# End Logging Section
#--------------------------------------------------------------------------------------------------

end_program(){
        cd $OriginalPath
        rm $PIDFile
        TotalSpentTime=$(echo $(date +%s.%N) $TotalStartTime | awk '{print $1 - $2}')
        test -z "$2" || ERROR "$2"
        INFO "End: $FullPath, TotalSpentTime=$TotalSpentTime exitcode=$1"
        exit $1
}

check_pid(){
	if ps waux | grep $Name | grep -q $(cat $PIDFile); then
		FATAL "$Name is running, PID=$(cat $PIDFile)"
	else
		WARN "PIDFile exist but $Name is NOT running: PIDFile=$PIDFile"
		rm $PIDFile
		INFO "PIDFile removed:PIDFile=$PIDFile"
	fi
}

INFO "Start: $FullPath $@"

test -f $PIDFile && check_pid
house_keep_logfile

echo $$ > $PIDFile

while getopts "ha:" c
do
	case $c in
		h) 
			echo "-h Help menu"
			end_program 0
		;;
		a)
			a=$OPTARG
		;;
	esac
done


#--------------------------------------------------------------------------------------------------
# Begin Main Program


# End Main Program
#--------------------------------------------------------------------------------------------------

end_program 0
