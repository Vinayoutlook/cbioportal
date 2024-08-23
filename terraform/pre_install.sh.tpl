
#!/bin/bash
aws configure set region us-west-2
DOCKER_COMPOSE_VERSION=2.2.2

{
    echo "Installing ssm agent -- Start"
    mkdir /tmp/ssm
    cd /tmp/ssm
    wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
    sudo dpkg -i amazon-ssm-agent.deb
    sudo systemctl enable amazon-ssm-agent
    echo "Installing ssm agent -- end"

    echo "Downloading Prisma Defender."
    cd /tmp; curl -u "${defender_user_name}:${defender_user_password}" -k -L -o twistcli https://us-east1.cloud.twistlock.com/us-2-158289582/api/v1/util/twistcli
    cd /tmp; chmod 755 ./twistcli

    echo "Initializing Prisma Defender."
    cd /tmp; ./twistcli defender install standalone host-linux --address  https://us-east1.cloud.twistlock.com/us-2-158289582 -u "${defender_user_name}" -p "${defender_user_password}"
    echo "Defender installation complete."

} &>> /usr/tmp/user-data.logs

exit
