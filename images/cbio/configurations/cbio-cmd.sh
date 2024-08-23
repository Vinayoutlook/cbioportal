#!/bin/sh
echo $IDP_METADATA >> /cbioportal-webapp/WEB-INF/classes/client-tailored-saml-idp-metadata.xml
java -Xms4g -Xmx32g \
-Dauthenticate=saml \
-Dsaml.sp.metadata.entitybaseurl=${ENTITY_BASE_URL} \
-Dsaml.idp.metadata.entityid=${ENTITY_ID} \
-Dsaml.keystore.password=${SAML_KEYSTORE_PASSWORD} \
-Dsaml.keystore.private-key.password=${SAML_KEYSTORE_PASSWORD} \
-Ddb.user=${DB_USER} \
-Ddb.password=${DB_PASSWORD} \
-Ddb.connection_string=${DB_CONNECTION_STRING} \
-Ddb.tomcat_resource_name=${DB_TOMCAT_RESOURCE_NAME} \
-Ddb.connection=${DB_CONNECTION} \
-Dpersistence.cache_type=${CACHE_TYPE} \
-Dredis.password=${REDIS_PASSWORD} \
-Dredis.leader_address=${REDIS_LEADER_ADDRESS} \
-Dredis.follower_address=${REDIS_FOLLOWER_ADDRESS} \
-Dredis.clear_on_startup=false \
-Dcache.endpoint.enabled=true \
-Dcache.endpoint.api-key=${CACHE_ENDPOINT_API_KEY} \
-Dsession.service.url=${SESSION_SERVICE_URL} \
-Dfrontend.config=classpath://frontendConfig.json \
-Dsaml.sp.metadata.entityid=${METADATA_ENTITY_ID} \
-Dgenomenexus.url=https://www.genomenexus.org -jar webapp-runner.jar --proxy-base-url ${BASE_URL} --enable-compression --path ${CONTEXT_PATH} /cbioportal-webapp