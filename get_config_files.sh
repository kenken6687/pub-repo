#!/bin/bash
####################################################
# Script name :get_config.sh
# Discription : Get config files program
# Output file : ${BASEDIR}/${BASENAME0}_dir/${BASENAME0}_${HOSTNAME}_${NAME_TIME}.tar.gz
# How to : # get_config.sh
#     $1 : -
#     $2 : -
#     Example: # get_config.sh
# Date : 2017/10/17
# Maker: Ka20
####################################################
HOSTNAME=`uname -n`
BASEDIR="$(cd $(dirname $0) && pwd)"
BASENAME=${0##*/}
BASENAME0=`basename $0 .sh`
LOGFILE=${BASEDIR}/${BASENAME0}.log
FLG=0

CONFIGLIST=${BASEDIR}/${BASENAME0}.list
NAME_TIME=`date +"%Y%m%d%H%M%S"`
COLLECTIONDIR=${BASEDIR}/${BASENAME0}_dir/${BASENAME0}_${HOSTNAME}_${NAME_TIME}
YN="N"

### output start log
TIME=`date +"%Y/%m/%d %H:%M:%S"`
echo "${TIME} ${HOSTNAME} ${BASENAME} I script start" >> ${LOGFILE}

### start check
echo -n "${BASENAME}. Start OK? [y/N]: "
read YN
case ${YN} in
    y|Y)
        echo "${TIME} ${HOSTNAME} ${BASENAME} I start check YES " >> ${LOGFILE}
        ;;
    *)
        TIME=`date +"%Y/%m/%d %H:%M:%S"`
        echo "${TIME} ${HOSTNAME} ${BASENAME} W start check NO " >> ${LOGFILE}
        echo "${TIME} ${HOSTNAME} ${BASENAME} I script end" >> ${LOGFILE}
        exit ${FLG}
        ;;
esac

### check configlist file
if [ ! -e ${CONFIGLIST} ] ; then
    TIME=`date +"%Y/%m/%d %H:%M:%S"`
    echo -e "${TIME} ${HOSTNAME} ${BASENAME} E Not found file ${BASENAME0}.list" | tee -a ${LOGFILE}
    echo "${TIME} ${HOSTNAME} ${BASENAME} I script end" >> ${LOGFILE}
    FLG=1
    exit ${FLG}
fi

grep -v '^#.*' ${CONFIGLIST} | grep -v '^$' > /dev/null
ERRORCHECK=`echo $?`
if [ ${ERRORCHECK} -ne 0 ] ; then
    TIME=`date +"%Y/%m/%d %H:%M:%S"`
    echo -e "${TIME} ${HOSTNAME} ${BASENAME} E Configlist all Comment line " | tee -a ${LOGFILE}
    echo "${TIME} ${HOSTNAME} ${BASENAME} I script end" >> ${LOGFILE}
    FLG=1
    exit ${FLG}
fi
TIME=`date +"%Y/%m/%d %H:%M:%S"`
echo "${TIME} ${HOSTNAME} ${BASENAME} I check configlist file OK " >> ${LOGFILE}

### make collection dir
if [ ! -e ${COLLECTIONDIR}.tar.gz ] ; then
    mkdir -p ${COLLECTIONDIR} > /dev/null 2>&1
    if [ ! -d ${COLLECTIONDIR} ] ; then
        TIME=`date +"%Y/%m/%d %H:%M:%S"`
        echo -e "${TIME} ${HOSTNAME} ${BASENAME} E Couldn't make directory ${COLLECTIONDIR}" | tee -a ${LOGFILE}
        echo "${TIME} ${HOSTNAME} ${BASENAME} I script end" >> ${LOGFILE}
        FLG=1
        exit ${FLG}
    fi
    TIME=`date +"%Y/%m/%d %H:%M:%S"`
    echo "${TIME} ${HOSTNAME} ${BASENAME} I maked collection dir" >> ${LOGFILE}
else
    TIME=`date +"%Y/%m/%d %H:%M:%S"`
    echo -e "${TIME} ${HOSTNAME} ${BASENAME} E Already maked file ${COLLECTIONDIR}.tar.gz" | tee -a ${LOGFILE}
    echo "${TIME} ${HOSTNAME} ${BASENAME} I script end" >> ${LOGFILE}
    FLG=1
    exit ${FLG}
fi

### get config files
echo "${TIME} ${HOSTNAME} ${BASENAME} I files copy start" >> ${LOGFILE}
while read CONFIGFILE
do
    SKIP_FLG=0
    CHK_FLG=0
    echo ${CONFIGFILE} | grep -v -e '^#.*' -v -e '^$' > /dev/null
    SKIP_FLG=`echo $?`

    if [ ${SKIP_FLG} -eq 0 ] ; then
        if [ -e ${CONFIGFILE} ] ; then
            DES_COPY_FILENAME=`echo "${CONFIGFILE}" | sed 's/\//__/g'`
            cp -p ${CONFIGFILE} ${COLLECTIONDIR}/${DES_COPY_FILENAME}
            CHK_FLG=1
        else
            TIME=`date +"%Y/%m/%d %H:%M:%S"`
            echo -e "${TIME} ${HOSTNAME} ${BASENAME} W not found ${CONFIGFILE}" | tee -a ${LOGFILE}
        fi
        if [ ${CHK_FLG} -eq 1 ] ; then
            if [ -e ${COLLECTIONDIR}/${DES_COPY_FILENAME} ] ; then
                TIME=`date +"%Y/%m/%d %H:%M:%S"`
                echo "${TIME} ${HOSTNAME} ${BASENAME} I copied ${CONFIGFILE}" >> ${LOGFILE}
            else
                TIME=`date +"%Y/%m/%d %H:%M:%S"`
                echo -e "${TIME} ${HOSTNAME} ${BASENAME} E couldn't copy file ${CONFIGFILE}" | tee -a ${LOGFILE}
            fi
        fi
    fi
done < ${CONFIGLIST}
echo "${TIME} ${HOSTNAME} ${BASENAME} I files copy end" >> ${LOGFILE}

### tar config files
cd ${BASEDIR}/${BASENAME0}_dir
tar cfz ${COLLECTIONDIR}.tar.gz ${COLLECTIONDIR##*/} > /dev/null
rm -rf ${COLLECTIONDIR##*/}
echo -e "${TIME} ${HOSTNAME} ${BASENAME} I output ${COLLECTIONDIR}.tar.gz" | tee -a ${LOGFILE}

### output end log
TIME=`date +"%Y/%m/%d %H:%M:%S"`
echo "${TIME} ${HOSTNAME} ${BASENAME} I script end" >> ${LOGFILE}

exit ${FLG}

