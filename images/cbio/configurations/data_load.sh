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
#for i in $(find /efs/studies/${env} -name "output_dir_${env}_*" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for AMEA
for i in $(find /efs/studies/${env} -name "output_dir_${env}_AMEA_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_AMEA_2.10" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_AMEA_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_AMEA_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_AMEA_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_AMEA_2.5" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_AMEA_2.7" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_AMEA_2.9" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

# #loading study for japan
for i in $(find /efs/studies/${env} -name "output_dir_${env}_japan_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_AMEA_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for BREAST
for i in $(find /efs/studies/${env} -name "output_dir_${env}_BREAST_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_BREAST_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_BREAST_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_BREAST_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_BREAST_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for GI
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GI_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GI_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GI_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GI_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GI_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for GU
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GU_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GU_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GU_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GU_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GU_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for GYN
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GYN_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GYN_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GYN_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GYN_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_GYN_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done


#loading study for LUNG
for i in $(find /efs/studies/${env} -name "output_dir_${env}_LUNG_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_LUNG_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_LUNG_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_LUNG_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_LUNG_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for OTHER
for i in $(find /efs/studies/${env} -name "output_dir_${env}_OTHER_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_OTHER_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_OTHER_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_OTHER_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_OTHER_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for phi_BREAST
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_BREAST_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_BREAST_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_BREAST_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_BREAST_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_BREAST_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for phi_GI
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GI_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GI_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GI_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GI_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GI_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for phi_GU
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GU_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GU_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GU_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GU_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GU_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for phi_GYN
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GYN_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GYN_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GYN_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GYN_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_GYN_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for phi_LUNG
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_LUNG_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_LUNG_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_LUNG_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_LUNG_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_LUNG_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done

#loading study for phi_OTHER
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_OTHER_2.10.1" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_OTHER_2.11" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_OTHER_2.12" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_OTHER_2.13" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
for i in $(find /efs/studies/${env} -name "output_dir_${env}_phi_OTHER_3.0" -type d); do ./importer/metaImport.py -p /portalinfo -s $i -v -o; done
