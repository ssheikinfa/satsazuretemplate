#!/bin/bash
#Purpose: To install EIC services
#Author: robsharm


echo "ulimit -n 32000" >> ~/.bashrc
ulimit -n 32000

#Installer Variables
installerLocation=/opt/Informatica/10.2.0/installer
installedLocation=/opt/Informatica/10.2.0/installed
licenseLocation=$1
encrptKeyDestLocation=$installedLocation/isp/config/keys/
licenseName="10.2.0_License_infadomainnode_8822"

#DB Variables
dbServerUser=$2
dbServerPassword=$3
dbServerName=$4
dbServerNameSuffix=".database.windows.net"
dbServerAddress="$dbServerName$dbServerNameSuffix"
dbServerPort="1433"
dbAccessSSLSuffix=";encryptionMethod=SSL;ValidateServerCertificate=true"
dbServerCompleteAddress="$dbServerAddress:$dbServerPort"

#Domain Variables
domainName="Domain"
domainUsername=$5
domainPassword=$6
domainDB=$7
domainNode="Node"
domainHostname=$(hostname -f)
domainDBServiceName="$domainDB$dbAccessSSLSuffix"

#Model Repository Service Variables
mrsName="Model_Repository_Service"
mrsContentsBackupPath=$installerLocation/mrsBackup/Latest_TTT_AfterDeletingDD.mrep
mrsDB=$8
mrsDBServiceName="$mrsDB$dbAccessSSLSuffix"

#Data Integration Service Variables
disName="Data_Integration_Service"
disDB=$9
pwhDataAccessConnectString="$dbServerAddress@$disDB"
pwhDBServiceName="$disDB$dbAccessSSLSuffix"

#Content Management Service Variables
cmsName="Content_Management_Service"
cmsDB=${10}
cmsDataAccessConnectString="$dbServerAddress@$cmsDB"
cmsDBServiceName="$cmsDB$dbAccessSSLSuffix"
cmsLaunchByInstaller="1"

#Catalog Service Variables
catName="Catalog_Service"
catalogBackup=$installerLocation/catalogBackup/TTT_Bkp_AfterAddingCustomAttribute.zip
underscore="_"
catalogHdfsDir="/Informatica/LDM/$domainName$underscore$catName"

#Cluster Variables
clusterName=${11}
clusterNameSuffix=".azurehdinsight.net"
clusterUrl="https://$clusterName$clusterNameSuffix"
clusterLoginUsername=${12}
clusterLoginPassword=${13}
clusterDistro="HortonWorks"
clusterSshAddressPrefix="$clusterName-ssh"
clusterSshAddress="$clusterSshAddressPrefix$clusterNameSuffix"
clusterSshUser=${14}
clusterSshPassword=${15}

sshpass -p $clusterSshPassword ssh -o StrictHostKeyChecking=no $clusterSshUser@$clusterSshAddress "sudo cp /usr/lib/hdinsight-common/scripts/decrypt.sh /tmp"
mkdir -p /usr/lib/hdinsight-common/scripts/
sshpass -p $clusterSshPassword scp  $clusterSshUser@$clusterSshAddress:/tmp/decrypt.sh /usr/lib/hdinsight-common/scripts/
sshpass -p $clusterSshPassword ssh -o StrictHostKeyChecking=no $clusterSshUser@$clusterSshAddress "sudo cp /usr/lib/hdinsight-common/certs/key_decryption_cert.prv /tmp"
mkdir -p /usr/lib/hdinsight-common/certs/
sshpass -p $clusterSshPassword scp  $clusterSshUser@$clusterSshAddress:/tmp/key_decryption_cert.prv /usr/lib/hdinsight-common/certs/
sshpass -p $clusterSshPassword ssh -o StrictHostKeyChecking=no $clusterSshUser@$clusterSshAddress "sudo hdfs dfs -mkdir -p $catalogHdfsDir"

#Updating SilentInput.properties


pathFormatforSed=`echo $licenseLocation | sed -e "s/\//\\\\\\\\\//g"`
sed -ie "s/^LICENSE_KEY_LOC=.*/LICENSE_KEY_LOC=$pathFormatforSed/" $installerLocation/SilentInput.properties

pathFormatforSed=`echo $installedLocation | sed -e "s/\//\\\\\\\\\//g"`
sed -ie "s/^USER_INSTALL_DIR=.*/USER_INSTALL_DIR=$pathFormatforSed/" $installerLocation/SilentInput.properties
 
pathFormatforSed=`echo $encrptKeyDestLocation | sed -e "s/\//\\\\\\\\\//g"`
sed -ie "s/^KEY_DEST_LOCATION=.*/KEY_DEST_LOCATION=$pathFormatforSed/" $installerLocation/SilentInput.properties

sed -ie "s/^DB_UNAME=.*/DB_UNAME=$dbServerUser/" $installerLocation/SilentInput.properties

sed -ie "s/^DB_PASSWD=.*/DB_PASSWD=$dbServerPassword/" $installerLocation/SilentInput.properties

sed -ie "s/^DB_SERVICENAME=.*/DB_SERVICENAME=$domainDBServiceName/" $installerLocation/SilentInput.properties

sed -ie "s/^DB_ADDRESS=.*/DB_ADDRESS=$dbServerCompleteAddress/" $installerLocation/SilentInput.properties

sed -ie "s/^DOMAIN_NAME=.*/DOMAIN_NAME=$domainName/" $installerLocation/SilentInput.properties

sed -ie "s/^DOMAIN_HOST_NAME=.*/DOMAIN_HOST_NAME=$domainHostname/" $installerLocation/SilentInput.properties

sed -ie "s/^NODE_NAME=.*/NODE_NAME=$domainNode/" $installerLocation/SilentInput.properties

sed -ie "s/^DOMAIN_USER=.*/DOMAIN_USER=$domainUsername/" $installerLocation/SilentInput.properties

sed -ie "s/^DOMAIN_PSSWD=.*/DOMAIN_PSSWD=$domainPassword/" $installerLocation/SilentInput.properties

sed -ie "s/^DOMAIN_CNFRM_PSSWD=.*/DOMAIN_CNFRM_PSSWD=$domainPassword/" $installerLocation/SilentInput.properties

sed -ie "s/^MRS_DB_UNAME=.*/MRS_DB_UNAME=$dbServerUser/" $installerLocation/SilentInput.properties

sed -ie "s/^MRS_DB_PASSWD=.*/MRS_DB_PASSWD=$dbServerPassword/" $installerLocation/SilentInput.properties

sed -ie "s/^MRS_DB_SERVICENAME=.*/MRS_DB_SERVICENAME=$mrsDBServiceName/" $installerLocation/SilentInput.properties

sed -ie "s/^MRS_DB_ADDRESS=.*/MRS_DB_ADDRESS=$dbServerCompleteAddress/" $installerLocation/SilentInput.properties

sed -ie "s/^MRS_SERVICE_NAME=.*/MRS_SERVICE_NAME=$mrsName/" $installerLocation/SilentInput.properties

sed -ie "s/^DIS_SERVICE_NAME=.*/DIS_SERVICE_NAME=$disName/" $installerLocation/SilentInput.properties

sed -ie "s/^PWH_DB_UNAME=.*/PWH_DB_UNAME=$dbServerUser/" $installerLocation/SilentInput.properties

sed -ie "s/^PWH_DB_PASSWD=.*/PWH_DB_PASSWD=$dbServerPassword/" $installerLocation/SilentInput.properties

sed -ie "s/^PWH_DB_SERVICENAME=.*/PWH_DB_SERVICENAME=$pwhDBServiceName/" $installerLocation/SilentInput.properties

sed -ie "s/^PWH_DB_ADDRESS=.*/PWH_DB_ADDRESS=$dbServerCompleteAddress/" $installerLocation/SilentInput.properties

sed -ie "s/^PWH_DATA_ACCESS_CONNECT_STRING=.*/PWH_DATA_ACCESS_CONNECT_STRING=$pwhDataAccessConnectString/" $installerLocation/SilentInput.properties

sed -ie "s/^LOAD_DATA_DOMAIN=.*/LOAD_DATA_DOMAIN=$cmsLaunchByInstaller/" $installerLocation/SilentInput.properties

sed -ie "s/^CMS_SERVICE_NAME=.*/CMS_SERVICE_NAME=$cmsName/" $installerLocation/SilentInput.properties

sed -ie "s/^CMS_DB_UNAME=.*/CMS_DB_UNAME=$dbServerUser/" $installerLocation/SilentInput.properties

sed -ie "s/^CMS_DB_PASSWD=.*/CMS_DB_PASSWD=$dbServerPassword/" $installerLocation/SilentInput.properties

sed -ie "s/^CMS_DB_SERVICENAME=.*/CMS_DB_SERVICENAME=$cmsDBServiceName/" $installerLocation/SilentInput.properties

sed -ie "s/^CMS_DB_ADDRESS=.*/CMS_DB_ADDRESS=$dbServerCompleteAddress/" $installerLocation/SilentInput.properties

sed -ie "s/^CMS_DATA_ACCESS_CONNECT_STRING=.*/CMS_DATA_ACCESS_CONNECT_STRING=$cmsDataAccessConnectString/" $installerLocation/SilentInput.properties

sed -ie "s/^CLUSTER_HADOOP_DISTRIBUTION_TYPE=.*/CLUSTER_HADOOP_DISTRIBUTION_TYPE=$clusterDistro/" $installerLocation/SilentInput.properties

sed -ie "s/^CATALOGUE_SERVICE_NAME=.*/CATALOGUE_SERVICE_NAME=$catName/" $installerLocation/SilentInput.properties

pathFormatforSed=`echo $clusterUrl | sed -e "s/\//\\\\\\\\\//g"`
sed -ie "s/^CLUSTER_HADOOP_DISTRIBUTION_URL=.*/CLUSTER_HADOOP_DISTRIBUTION_URL=$pathFormatforSed/" $installerLocation/SilentInput.properties

sed -ie "s/^CLUSTER_HADOOP_DISTRIBUTION_URL_USER=.*/CLUSTER_HADOOP_DISTRIBUTION_URL_USER=$clusterLoginUsername/" $installerLocation/SilentInput.properties

sed -ie "s/^CLUSTER_HADOOP_DISTRIBUTION_URL_PASSWD=.*/CLUSTER_HADOOP_DISTRIBUTION_URL_PASSWD=$clusterLoginPassword/" $installerLocation/SilentInput.properties

echo "Running Informatica Silent Installer..."
cd $installerLocation
./silentinstall.sh



