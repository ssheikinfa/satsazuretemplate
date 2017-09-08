#!/bin/bash
#Purpose: To install EIC services
#Author: robsharm

#Installer Variables
installerLocation=/opt/Informatica/10.2.0/installer
installedLocation=/opt/Informatica/10.2.0/installed
licenseLocation=$1
encrptKeyDestLocation=$installedLocation/isp/config/keys/
licenseName="10.2.0_Services_License"
javaBinDir=/opt/java/jdk1.8.0_144/bin

#DB Variables
dbServerUser=$2
dbServerPassword=$3
dbServerName=$4
dbServerNameSuffix=".database.windows.net"
dbServerAddress="$dbServerName$dbServerNameSuffix"
dbServerPort="1433"
dbAccessSSLSuffix=";encryptionMethod=SSL;ValidateServerCertificate=true"
dbServerCompleteAddress="$dbServerAddress:$dbServerPort"
dbType="MSSQLServer"

#Domain Variables
domainName="Domain"
domainUsername=$5
domainPassword=$6
domainDB=$7
domainNode="Node"
domainHostname=$(hostname)
domainDBServiceName="$domainDB$dbAccessSSLSuffix"
createServices="0"

#Model Repository Service Variables
mrsName="Model_Repository_Service"
mrsContentsBackupPath=$installerLocation/dataBackup/mrsBackup.mrep
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

#Catalog Service Variables
catName="Catalog_Service"
catalogBackup=$installerLocation/dataBackup/ldmBackup.zip
underscore="_"
catalogHdfsDir="/Informatica/LDM/$domainName$underscore$catName"
loadType=${11}
importSampleData=${12}


#Cluster Variables
clusterName=${13}
clusterNameSuffix=".azurehdinsight.net"
clusterUrl="https://$clusterName$clusterNameSuffix"
clusterLoginUsername=${14}
clusterLoginPassword=${15}
clusterDistro="HortonWorks"
clusterSshAddressPrefix="$clusterName-ssh"
clusterSshAddress="$clusterSshAddressPrefix$clusterNameSuffix"
clusterSshUser=${16}
clusterSshPassword=${17}

#Analyst Service Variables
analystServiceName=Analyst_Service

ulimit -n 32000

#Getting storage account key and certificate
sshpass -p $clusterSshPassword ssh -o StrictHostKeyChecking=no $clusterSshUser@$clusterSshAddress "sudo cp /usr/lib/hdinsight-common/scripts/decrypt.sh /tmp"
mkdir -p /usr/lib/hdinsight-common/scripts/
sshpass -p $clusterSshPassword scp -o StrictHostKeyChecking=no $clusterSshUser@$clusterSshAddress:/tmp/decrypt.sh /usr/lib/hdinsight-common/scripts/
sshpass -p $clusterSshPassword ssh -o StrictHostKeyChecking=no $clusterSshUser@$clusterSshAddress "sudo cp /usr/lib/hdinsight-common/certs/key_decryption_cert.prv /tmp"
mkdir -p /usr/lib/hdinsight-common/certs/
sshpass -p $clusterSshPassword scp -o StrictHostKeyChecking=no $clusterSshUser@$clusterSshAddress:/tmp/key_decryption_cert.prv /usr/lib/hdinsight-common/certs/

#Creating Catalog Service HDFS Directory
sshpass -p $clusterSshPassword ssh -o StrictHostKeyChecking=no $clusterSshUser@$clusterSshAddress "sudo hdfs dfs -mkdir -p $catalogHdfsDir"

#Updating SilentInput.properties


pathFormatforSed=`echo $licenseLocation | sed -e "s/\//\\\\\\\\\//g"`
sed -i -e "s/^LICENSE_KEY_LOC=.*/LICENSE_KEY_LOC=$pathFormatforSed/" $installerLocation/SilentInput.properties

pathFormatforSed=`echo $installedLocation | sed -e "s/\//\\\\\\\\\//g"`
sed -i -e "s/^USER_INSTALL_DIR=.*/USER_INSTALL_DIR=$pathFormatforSed/" $installerLocation/SilentInput.properties
 
pathFormatforSed=`echo $encrptKeyDestLocation | sed -e "s/\//\\\\\\\\\//g"`
sed -i -e "s/^KEY_DEST_LOCATION=.*/KEY_DEST_LOCATION=$pathFormatforSed/" $installerLocation/SilentInput.properties

sed -i -e "s/^DB_UNAME=.*/DB_UNAME=$dbServerUser/" $installerLocation/SilentInput.properties

sed -i -e "s/^DB_PASSWD=.*/DB_PASSWD=$dbServerPassword/" $installerLocation/SilentInput.properties

sed -i -e "s/^DB_SERVICENAME=.*/DB_SERVICENAME=$domainDBServiceName/" $installerLocation/SilentInput.properties

sed -i -e "s/^DB_ADDRESS=.*/DB_ADDRESS=$dbServerCompleteAddress/" $installerLocation/SilentInput.properties

sed -i -e "s/^DOMAIN_NAME=.*/DOMAIN_NAME=$domainName/" $installerLocation/SilentInput.properties

sed -i -e "s/^DOMAIN_HOST_NAME=.*/DOMAIN_HOST_NAME=$domainHostname/" $installerLocation/SilentInput.properties

sed -i -e "s/^NODE_NAME=.*/NODE_NAME=$domainNode/" $installerLocation/SilentInput.properties

sed -i -e "s/^DOMAIN_USER=.*/DOMAIN_USER=$domainUsername/" $installerLocation/SilentInput.properties

sed -i -e "s/^DOMAIN_PSSWD=.*/DOMAIN_PSSWD=$domainPassword/" $installerLocation/SilentInput.properties

sed -i -e "s/^DOMAIN_CNFRM_PSSWD=.*/DOMAIN_CNFRM_PSSWD=$domainPassword/" $installerLocation/SilentInput.properties

sed -i -e "s/^CREATE_SERVICES=.*/CREATE_SERVICES=$createServices/" $installerLocation/SilentInput.properties

#Updating Config template for Mercury installer

pathFormatforSed="$installerLocation/"
pathFormatforSed=`echo $pathFormatforSed | sed -e "s/\//\\\\\\\\\//g"`
sed -i -e "s/installerPath/$pathFormatforSed/g" $installerLocation/config_template.xml

pathFormatforSed="$installedLocation/"
pathFormatforSed=`echo $pathFormatforSed | sed -e "s/\//\\\\\\\\\//g"`
sed -i -e "s/installedPath/$pathFormatforSed/g" $installerLocation/config_template.xml

sed -i -e "s/domainname/$domainName/g" $installerLocation/config_template.xml

sed -i -e "s/nodename/$domainNode/g" $installerLocation/config_template.xml

sed -i -e "s/DomainHostValue/$domainHostname/g" $installerLocation/config_template.xml

sed -i -e "s/adminusername/$domainUsername/g" $installerLocation/config_template.xml

sed -i -e "s/adminpassword/$domainPassword/g" $installerLocation/config_template.xml

sed -i -e "s/dbtypevalue/$dbType/g" $installerLocation/config_template.xml

sed -i -e "s/dbloginvalue/$dbServerUser/g" $installerLocation/config_template.xml

sed -i -e "s/dbpasswordvalue/$dbServerPassword/g" $installerLocation/config_template.xml

sed -i -e "s/dbhostname/$dbServerAddress/g" $installerLocation/config_template.xml

sed -i -e "s/dbportvalue/$dbServerPort/g" $installerLocation/config_template.xml

sed -i -e "s/dbservicenamevalue/$domainDBServiceName/g" $installerLocation/config_template.xml

sed -i -e "s/dbservicenamevalue/$domainDBServiceName/g" $installerLocation/config_template.xml

pathFormatforSed=`echo $licenseLocation | sed -e "s/\//\\\\\\\\\//g"`
sed -i -e "s/licenseLocation/$pathFormatforSed/g" $installerLocation/config_template.xml

sed -i -e "s/licensename/$licenseName/g" $installerLocation/config_template.xml

sed -i -e "s/cmsdbname/$cmsDBServiceName/g" $installerLocation/config_template.xml

sed -i -e "s/pwhdbname/$pwhDBServiceName/g" $installerLocation/config_template.xml

sed -i -e "s/Model_Repository_Service/$mrsName/g" $installerLocation/config_template.xml

sed -i -e "s/mrsservicename/$mrsDBServiceName/g" $installerLocation/config_template.xml

pathFormatforSed=`echo $mrsContentsBackupPath | sed -e "s/\//\\\\\\\\\//g"`
sed -i -e "s/mrsBackupFile/$pathFormatforSed/g" $installerLocation/config_template.xml

sed -i -e "s/Data_Integration_Service/$disName/g" $installerLocation/config_template.xml

sed -i -e "s/Data_Integration_Service/$disName/g" $installerLocation/config_template.xml

sed -i -e "s/Content_Management_Service/$cmsName/g" $installerLocation/config_template.xml

sed -i -e "s/importsampledata/$importSampleData/g" $installerLocation/config_template.xml



echo "Running Informatica Installer..."
$javaBinDir/java -jar $installerLocation/mercuryInstaller/mercury_setup.jar -cf $installerLocation/config_template.xml -s -uei

echo "Creating Catalog Service..."
$installedLocation/isp/bin/infacmd.sh  LDM createService -dn $domainName -nn $domainNode -un $domainUsername -pd $domainPassword -mrs $mrsName -mrsun Administrator -mrspd Administrator -dis $disName -sn $catName -p 6705 -ise true -chdt HortonWorks -chdu $clusterUrl -chduu $clusterLoginUsername -chdup $clusterLoginPassword

echo "Assigning License to Catalog Service..."
$installedLocation/isp/bin/infacmd.sh  assignLicense -dn $domainName -un $domainUsername -pd $domainPassword -ln $licenseName -sn $catName

echo "Setting Load Type for Catalog Service..."
$installedLocation/isp/bin/infacmd.sh  ldm updateServiceOptions -dn $domainName -un $domainUsername -pd $domainPassword -sn $catName -o "LdmCustomOptions.loadType=$loadType"

echo "Restoring Catalog Service Sample Contents..."
$installedLocation/isp/bin/infacmd.sh ldm restoreContents -dn $domainName -un $domainUsername -pd $domainPassword -sn $catName -if $catalogBackup

sleep 15

echo "Enabling Catalog Service..."
$installedLocation/isp/bin/infacmd.sh enableService -dn $domainName -un $domainUsername -pd $domainPassword -sn $catName

echo "Creating Analyst Service..."
$installedLocation/isp/bin/infacmd.sh as createService -dn $domainName -nn $domainNode -sn $analystServiceName -un $domainUsername -pd $domainPassword -rs $mrsName -ds $disName -ffl /tmp -cs $catName -csau Administrator -csap Administrator -au Administrator -ap Administrator -bgefd /tmp -HttpPort 8089

echo "Assigning License to Analyst Service..."
$installedLocation/isp/bin/infacmd.sh  assignLicense -dn $domainName -un $domainUsername -pd $domainPassword -ln $licenseName -sn $analystServiceName

echo "Enabling Analyst Service..."
$installedLocation/isp/bin/infacmd.sh enableService -dn $domainName -un $domainUsername -pd $domainPassword -sn $analystServiceName
