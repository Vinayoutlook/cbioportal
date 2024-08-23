# Load the studies
mkdir -p /efs/studies/
if [ "$account" = "dpp" ] || [ "$account" = "dpnp" ]
then
  aws s3 cp s3://gh-dp-data-${env}-ecbio-data-asset/data/ /efs/studies/ --recursive
else
  aws s3 cp s3://gh-dp-data-${account}-${env}-ecbio-data-asset/data/ /efs/studies/ --recursive
fi

# Create portal.properties
{
  echo "db.user="${DB_USER}
  echo "db.password="${DB_PASSWORD}
  echo "db.host="${DB_HOST}
  echo "db.portal_db_name="${PORTAL_DB_NAME}
  echo "db.driver="${DB_DRIVER}
  echo "db.connection_string="${DB_CONNECTION_STRING}
  echo "db.use_ssl=false"
} > /cbioportal/portal.properties

sleep 5
cd /cbioportal/core/src/main/scripts/


# Load Gene panels
for i in $(find /efs/studies/${env}/output_dir_${env}/gene_panels/gene*); do ./importGenePanel.pl --data $i; done

# Cretae the Portal Information
perl ./dumpPortalInfo.pl /portalinfo

#loading all the studies rather than individual studies
for i in $(find /efs/studies/${env} -name "output_dir_${env}_*" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
#for i in $(find /efs/studies/${env} -name "output_dir_dev_phi_GI_2.10" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
