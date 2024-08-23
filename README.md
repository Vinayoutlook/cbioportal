### Platform Component - ecBio Portal

#### Description
The cBioPortal provides an exploratory analysis for exploring large-scale cancer genomic data sets using a variety of visualization and analytical tools and “gene-based” visualizations and analyses, so that users can find altered genes and/or networks within a study of interest or across all studies. It allows users to interrogate datasets across genes, samples, and data types, giving them the opportunity to examine several different biologically and/or clinically relevant hypotheses.

#### Data Custodian:
- gh-pyenduri

#### Top 5 Contributors:
- gh-siyengar
- gh-sadari
- gh-bbolisetty
- gh-jvirdee
- gh-dsawale


#### Runbook Link
- [DP - Runbook - ecBio Portal](https://guardanthealth.atlassian.net/wiki/spaces/DP/pages/3407020069/DP+-+Runbook+-+ecBio+Portal)
####

#### Data Flow
    The following is happening in the Airflow

    GH Inform Database → Batch Code (Python code generate studies) → S3 → Batch Code → CBIO

#### Consideration:

    If we need, we can also use Spark on GHInform Database to filter out part of the data that is required by python code.
    There will be exactly two repositories
    Terraform CBio

    Data from S3 to Sql - Docker
     DockerFIle and Image will be pushed to ECR maintained by us.
     This docker image will be used by Data Team in their Batch Module. and input parameters will have the location of studies.

**** Test cases To be executed after every deployment of the cbio application in production after deployment ****
#### Mandatory : User to be added in  cbio OKTA tile and connect to VPN : vpn.guardanthealth.com ####
#### Testcase1:
    step1: Access cbio application by clicking on the okta tile : CBio
    step2: Select the 1 or 2 studies by clicking on checkbox
    step3: click on "Explore Selected Studies"
    step4: Able to view the graphical representation of cancer related data

#### Testcase2:
    step1: Follow same steps in Testcase1 
    step2: Select 4 or 5 genes from Mutated Genes
    step3: Click on Query option on the top right corner 
    step4: Able to view OncoPrint View 
    step5: Navigate to the different tabs in the same page:  Cancer Type Summary, Mutual Exclusivity, Plots, Mutations, Comparison etc...
    step6: Able to view the data without any errors and exceptions