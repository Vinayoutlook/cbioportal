FROM baslee/cbioportal:gh-5.2.0-namespaces-columns-lazytable-sv-fix-logging-fiximportlong-submit-t3
RUN apt update && apt install curl procps -y
RUN mkdir -p /cbioportal /cbioportal-webapp/images /WEB-INF/classes
COPY configurations/portal.properties /cbioportal/portal.properties
COPY configurations/custom_logo.png /cbioportal-webapp/images/custom_logo.png
COPY configurations/seed_database.sql /.
COPY configurations/data_load.sh /cbioportal/data_load.sh
COPY configurations/samlKeystore.jks /cbioportal-webapp/WEB-INF/classes/samlKeystore.jks
COPY configurations/cbio-cmd.sh /.
RUN chmod 500 /cbioportal/data_load.sh /cbio-cmd.sh
RUN apt update \
    && apt install curl \
    && apt install unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install
COPY configurations/cgds.sql /.
WORKDIR /