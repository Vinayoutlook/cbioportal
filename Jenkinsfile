//@Library("shared-library") _

pipeline {
    agent {
        label 'builds'
    }
    parameters{
        choice(
                name: 'TARGET_ACCOUNT',
                //choices: getSupportedAccounts(account:account_name)
                choices: getSupportedAccounts(account:ACCOUNT_NAME),
                description: 'Infra deployment based on aws account'
        )
        choice(
                name: 'TARGET_WORKSPACE',
                //choices: getSupportedAccounts(account:account_name)
                choices: getEnvironmentList(account:ACCOUNT_NAME),
                description: 'Infra deployment workspace'
        )
        booleanParam(
            name: "CBIO_IMAGE",
            //defaultValue: false
            defaultValue: true,
            description: "This will create image for the cbio & push to ECR"
        )
        booleanParam(name: 'APPLY', defaultValue: false, description: 'The infra will be applied to the chosen workspace.')
    }
    environment {
        //REGION = 'us-west-2'
        REGION = 'us-east-1'
        //ACCOUNT_NAME = credentials('account_name')
        ACCOUNT_NAME = 'administratortksr'
        //ACCOUNT_ID = credentials('account_id')
        ACCOUNT_ID = 'tksr'
        //DOCKER_HOST = credentials("${dockerHostGetString(account:env.ACCOUNT_NAME)}")
        DOCKER_HOST = credentials("${dockerHostGetString(account:env.ACCOUNT_ID)}")
    }
    tools {
        dockerTool 'docker'
        //dockerTool 'myDocker'
    }
    stages {
        stage('Download Dependencies'){
            steps{
                dir('terraform'){
                    downloadDependencies(
                            directory: ".dependencies",
                            repository:"gh-org-data-platform/terraform-aws-gh-dp-glue",
                            //account:"${env.ACCOUNT_NAME}"
                            account:"${env.ACCOUNT_NAME}",
                            branch: "feature/EPPE-3738-TECHNICAL-ecbio-env-instance"
                    )
                }
            }
        }
        stage("Initialize Workspace"){
            steps{
                dir('terraform'){
                    initWorkspaceV2(
                            repo:"${env.GIT_URL}",
                            //account:"${env.ACCOUNT_NAME}"
                            account:"${env.ACCOUNT_ID}",
                            env: "${params.TARGET_WORKSPACE}",
                            targetAccount: "${params.TARGET_ACCOUNT}"
                    )
                }
            }
        }
        stage("CBIO Portal Image") {
            when {expression { params.CBIO_IMAGE == true }}
            steps{
                script {
                    if (params.TARGET_ACCOUNT == 'dpnp' || params.TARGET_ACCOUNT == 'dpp') {
                        dir('images/cbio') {
                            dockerBuild(
                                    account: env.ACCOUNT_NAME,
                                    account_id: env.ACCOUNT_ID,
                                    targetAccount: "${params.TARGET_ACCOUNT}",
                                    branch: env.BRANCH_NAME,
                                    image_repo: "dp-tools-repositories-cbioportal",
                                    version: "latest"
                            )
                        }
                    }
                    else if (params.TARGET_ACCOUNT == 'dpenp' || params.TARGET_ACCOUNT == 'dpep') {
                        dir('images/cbio-ext') {
                            dockerBuild(
                                    account: env.ACCOUNT_NAME,
                                    account_id: env.ACCOUNT_ID,
                                    targetAccount: "${params.TARGET_ACCOUNT}",
                                    branch: env.BRANCH_NAME,
                                    image_repo: "dp-tools-repositories-cbioportal",
                                    version: "latest"
                            )
                        }
                    }
                }
            }
        }
        stage("Validate & Plan") {
            steps {
                dir('terraform') {
                    validateAndPlan(
                            account:"${env.ACCOUNT_NAME}",
                            env: "${params.TARGET_WORKSPACE}",
                            targetAccount: "${params.TARGET_ACCOUNT}",
                            sendSupportEnvConf: true
                    )
                }
            }
        }
        stage("Apply") {
            when {expression { params.APPLY == true }}
            steps {
                dir('terraform') {
                    terraformApply(
                            account:"${env.ACCOUNT_NAME}",
                            apply: "${params.APPLY}",
                            branch: env.BRANCH_NAME,
                            env: "${params.TARGET_WORKSPACE}",
                            targetAccount: "${params.TARGET_ACCOUNT}",
                            sendSupportEnvConf: true
                    )
                }
            }
        }
    }
 post {
        always {
            pushLogsAndMetadata()
        }
    }
}
