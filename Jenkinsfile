#!groovy

//  Please refer to the following links that may contain usefull information:
//  Based on: https://github.com/forcedotcom/sfdx-jenkins-org
// 
// - https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ci_jenkins_sample_walkthrough.htm
// - https://plugins.jenkins.io/bitbucket-push-and-pull-request/


node {
    // Local Variables 
    String AA_WORK_ITEM //Agile Accelerator work item number
    String JOBIDDEPLOY
    def SOURCE_BRANCH
    def TARGET_BRANCH
    def SCMVARS
    def SF_USERNAME
    def SF_TARGET_ENV
    def SF_INSTANCE_URL
    def SF_CONSUMER_KEY
    def SF_CONSUMER_SERVER_KEY
    def SF_TEST_LEVEL='RunLocalTests'
    env.LANG    = "en_US.UTF-8"
    try {
	  //---------------------------------------------------------------------------------
        //Getting the source and target branch from user
	  //---------------------------------------------------------------------------------
	  SOURCE_BRANCH = input message: 'Please enter the source branch',
                             parameters: [string(defaultValue: '',
                                          description: '',
                                          name: 'sourceb')]
	  TARGET_BRANCH = input message: 'enter the target branch',
                             parameters: [password(defaultValue: '',
                                          description: '',
                                          name: 'targetb')]
	    echo "source branch is: ${SOURCE_BRANCH}"
	    echo "target branch is: ${TARGET_BRANCH}"

        // ----------------------------------------------------------------------------------
        // Run all the enclosed stages with access to the Salesforce
        // JWT key credentials.
        // ----------------------------------------------------------------------------------
        withEnv(["HOME=${env.WORKSPACE}"]) {
            SF_USERNAME = "ENV_HOS_CIONE_USERNAME"
            SF_CONSUMER_KEY = "ENV_HOS_CIONE_CLIENT"
            SF_CONSUMER_SERVER_KEY = "ENV_HOS_CIONE_SERVERKEY" //Serverkey
            SF_INSTANCE_URL = "https://test.salesforce.com"
            // Based on the source and target branches, set SF_* variables for authentication withing sfdx
            if ( ("${SOURCE_BRANCH}".contains("feature/") || "${SOURCE_BRANCH}".contains("hotfix/") ) && "${TARGET_BRANCH}".contains("develop")) {
                SF_USERNAME = "ENV_HOS_QA_USERNAME"
                SF_CONSUMER_KEY = "ENV_HOS_QA_CLIENT"
                SF_CONSUMER_SERVER_KEY = "ENV_HOS_QA_SERVERKEY" //Serverkey
                SF_TARGET_ENV = "cidevone"
            } else if ("${TARGET_BRANCH}".contains("release/")) {
                SF_USERNAME = "ENV_HOS_CIONE_USERNAME" 
                SF_CONSUMER_KEY = "ENV_HOS_CIONE_CLIENT" 
                SF_CONSUMER_SERVER_KEY = "ENV_HOS_CIONE_SERVERKEY" 
                SF_TARGET_ENV = "ahuat" 
            } else if ("${SOURCE_BRANCH}".contains("release/") && "${TARGET_BRANCH}".contains("master")) {
                SF_USERNAME = "ENV_HOS_PROD_USERNAME" // FIXME
                SF_CONSUMER_KEY = "ENV_HOS_PROD_CLIENT" // FIXME
                SF_CONSUMER_SERVER_KEY = "ENV_HOS_PROD_SERVERKEY" // FIXME
                SF_TARGET_ENV = "ahprod" 
                SF_INSTANCE_URL = "https://login.salesforce.com"
            }

            // Print some usefull info
            echo "Salesforce User: ${SF_USERNAME}"
            echo "Source branch: ${SOURCE_BRANCH}"
            echo "Target: ${TARGET_BRANCH}"
            
            // ----------------------------------------------------------------------------------
            // Get server key file to connect with the connected app.
            // ----------------------------------------------------------------------------------
            withCredentials([
                file(credentialsId: "${SF_CONSUMER_SERVER_KEY}", variable: 'CONSUMER_SERVER_KEY'),
                string(credentialsId: "${SF_USERNAME}", variable: 'USERNAME'),
                string(credentialsId: "${SF_CONSUMER_KEY}", variable: 'CONSUMER_KEY')
            ]) {
        
                // Print some usefull info
                echo "Salesforce User: ${SF_USERNAME}"
                echo "Salesforce Username: ${USERNAME}"
				
				
				// ----------------------------------------------------------------------------------
                // Set the target org, instance URL to be used. Clone the repo and authorize 
                // connection to SF org.
                // ----------------------------------------------------------------------------------
                stage('Build Setup (Org, Repo)') {

                     // Clean the workspace in case previous build ended in Failure and cleanup wasn't performed.
                    cleanWs()
                    // Print some usefull info
                    echo "Salesforce target env: ${SF_TARGET_ENV}"
                    echo "Bitbucket source branch: ${SOURCE_BRANCH}"
                    echo "Bitbucket target branch: ${TARGET_BRANCH}"
                    echo "Salesforce url:${SF_INSTANCE_URL}"
                    // Clone repo and checkout to desired 
                    SCMVARS = checkout([
                         $class: 'GitSCM', 
                        branches: [[name: "${SOURCE_BRANCH}"]], 
				doGenerateSubmoduleConfigurations: false,
                        extensions: [[$class: 'WipeWorkspace']],
				submoduleCfg: [],
                        userRemoteConfigs: [[
                            credentialsId: 'ENV_MANISH_GIT_CRED',
                            url: 'https://mkumar7@rndwww.nce.amadeus.net/git/scm/ahsf/salesforce.git'
                        ]]
                    ])

                    rc = commandStatus "git config --global core.longpaths true"
			  // Configure git variables using the ones from Jenkins global config
                    commandOutput "git config user.email \"$SCMVARS.GIT_AUTHOR_EMAIL\""
                    commandOutput "git config user.name \"$SCMVARS.GIT_AUTHOR_NAME\""



                    // Authorize connections through sfdx to Salesforce org
                    rc = commandStatus "sfdx auth:jwt:grant --instanceurl ${SF_INSTANCE_URL} --clientid ${CONSUMER_KEY} --jwtkeyfile ${CONSUMER_SERVER_KEY} --username ${USERNAME} --setalias ${SF_TARGET_ENV}"
                    if (rc != 0) {
                        error 'Salesforce org authorization failed.'
                    }
                }

                // ----------------------------------------------------------------------------------
                // Perform static analisys on the code using Sonarqube-runner
                // This assumes that there's a 'sonar-project.properties' file on git.
                // ----------------------------------------------------------------------------------
                /*
                // Not in use for the scope of analysis
                stage('Run Code Quality Analysis(PMD)'){
                     
                    FIXME waiting confirmation that Jenkisn has access to the web
                    Download pmd from GitHub 
                    if (isUnix()) {
                        rc = commandStatus "curl -L -o pmd-bin-6.39.0.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.39.0/pmd-bin-6.39.0.zip"
                    } else {
                        rc = commandStatus "bitsadmin /transfer debjob /download /priority normal https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.39.0/pmd-bin-6.39.0.zip %CD%/pmd-bin-6.39.0.zip "
                    }
                    if (rc != 0) {
                        error "Failed to download PMD from GitHub"
                    }

                    Extract pmd
                       rc = commandStatus "jar xf pmd-bin-6.39.0.zip"
                    if (rc != 0) {
                       error "Failed to extract pmd-bin-6.39.0.zip"
                    }

                    Run pmd
                    String pmdRunner

                    if (isUnix()) {
                     pmdRunner = "bash pmd-bin-6.39.0/bin/run.sh pmd"
                    } else {
                     pmdRunner = "pmd-bin-6.39.0/bin/pmd.bat"
                    }

                    rc = commandStatus "${pmdRunner} -d ./force-app/main/default/ -R ./config/pmd/apex/apex_ruleset.xml,./config/pmd/vf/security.xml -f summaryhtml -reportfile ./apex_security_pmd.html -no-cache -failOnViolation false"
                    if (rc != 0) {
                     error "Failed to run PMD analysis."
                    }

                    Archive report
                    archiveArtifacts artifacts: 'apex_security_pmd.html', followSymlinks: false

                    Delete files
                    rc = commandStatus "rm -r pmd-bin-6.39.0*"
                    rc = commandStatus "rm apex_security_pmd.html"
                    echo "PMD: ${rc}" 
                    
                }
                */
                // ----------------------------------------------------------------------------------
                // Run the sonar quality gates
                // ----------------------------------------------------------------------------------
                stage('Run Code Quality Analysis (SonarQube)') {
                    def userInput = input(message: 'Do you want to run Sonar quality analysis ?', ok: 'Continue', 
                                        parameters: [choice(choices: ['Yes', 'No'], 
                                                        description: 'Continue to next stage', 
                                                        name: 'sonarValidation')])

                        if (userInput == 'Yes') 
                        {	
                            // Run SonarQube Analysis
                            withSonarQubeEnv('Sonar') {
                                //    rc = commandStatus "sonar-scanner"
                                rc = commandStatus "sonar-scanner -D sonar.pullrequest.key=${env.BITBUCKET_PULL_REQUEST_ID} -D sonar.pullrequest.branch=${env.BITBUCKET_SOURCE_BRANCH} -Dsonar.pullrequest.base=${env.BITBUCKET_TARGET_BRANCH}"
                            
                                if (rc != 0) {
                                    error 'Failed to start sonar-scanner'
                                }
                            }
                        }
                         else {
                            echo 'Skipped to sonar quality verification'
                        } 
                   
                }

                // ----------------------------------------------------------------------------------
                // Run the LocalTests on the Salesforce org for a given AA_WORK_ITEM
                // ----------------------------------------------------------------------------------
                stage('Validate (RunLocalTests, jest)') {
                    
                    String CURRENT_BRANCH = "${env.SOURCE_BRANCH}"
                    AA_WORK_ITEM = CURRENT_BRANCH.substring(CURRENT_BRANCH.indexOf('/') + 1, CURRENT_BRANCH.length())

                    String JOB = commandOutput "sfdx force:source:deploy -u ${SF_TARGET_ENV} -l RunLocalTests -w 40 -c -x manifest/${AA_WORK_ITEM}/package.xml"
                    def idPosition = JOB.indexOf("Job ID") + 9
                    
                    JOBIDDEPLOY =  JOB.substring(idPosition,idPosition+15).trim()
                    echo "JOBIDDEPLOY: ${idPosition}  :  ${JOBIDDEPLOY}"
                   
                    if ("${JOB}".contains("Success")) {
                        JOBIDDEPLOY =  JOB.substring(idPosition,idPosition+15).trim()
                        echo "JOBIDDEPLOY: ${idPosition}  :  ${JOBIDDEPLOY}"
                    }else if ("${JOB}".contains("Failed")) {
                        error 'Salesforce RunLocalTests failed.'
                    }
                }
                // ----------------------------------------------------------------------------------
                // Run the LocalTests on the Salesforce org for a given AA_WORK_ITEM
                // ----------------------------------------------------------------------------------
                stage('PR Approval?') {

                        def userInput = input(message: 'PR is approved and move to next stage ?', ok: 'Continue', 
                                        parameters: [choice(choices: ['Yes', 'No'], 
                                                        description: 'Continue to next stage', 
                                                        name: 'prapproval')])

                        if (userInput == 'Yes') 
                        {	
                            echo 'PR is approved and continue to next stage'
                            
                        }
                        else {
                            
                        } 
                }

                // ----------------------------------------------------------------------------------
                // Deploy the package previously validated on stage "Run Test (RunLocalTests, jest)"
                // ----------------------------------------------------------------------------------
                stage('Promote to QA (deploy package + validation)') {
                    
                    rc = commandStatus "sfdx force:source:deploy -u ${SF_TARGET_ENV} -w 10 -q ${JOBIDDEPLOY}"
                    //rc = commandStatus "sfdx force:source:deploy -u ${SF_TARGET_ENV} -w 10 -l NoTestRun -x manifest/${AA_WORK_ITEM}/package.xml"
                    if (rc != 0) {
                        error 'Salesforce deployment failed.'
                    }
                }
                stage('Merging') {
                    
                    // Logout from SFDX
                    rc = commandStatus "sfdx auth:logout --targetusername ${SF_TARGET_ENV}"
                    if (rc != 0) {
                        error 'Salesforce logout failed.'
                    }

                    // Merge the PR on BitBucket
                    // Checkout to source branch (so we can have a local copy)
                    rc = commandStatus "git checkout ${SOURCE_BRANCH}"
                    if (rc != 0) {
                        error 'Failed to checkout to source branch.'
                    }
                    
                    // Checkout to target branch
                    rc = commandStatus "git checkout ${TARGET_BRANCH}"
                    if (rc != 0) {
                        error 'Failed to checkout to target branch.'
                    }

                    // Merge source branch into target branch. Squash commits into just one.
                    rc = commandStatus "git merge ${SOURCE_BRANCH}"
                    if (rc != 0) {
                        error 'Failed to merge source branch into target branch.'
                    }

                    // Push changes back to BitBucket
                    withCredentials([usernamePassword(credentialsId: 'ENV_GALAXY_CRM_BITBUCKET', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        rc = commandStatus "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@rndwww.nce.amadeus.net/git/scm/cgal/crm.git"
                        if (rc != 0) {
                            error 'Failed to push merge to BitBucket.'
                        }
                    } 
                }

                // ----------------------------------------------------------------------------------
                //  Validate package
                // ----------------------------------------------------------------------------------
                stage('Notify Reviewers') {

                }
            }
        }
    } catch (e) {
        throw e
    } finally {
        
        // Send email. Uses the configs from Manage Jenkins > Configure System > Extended E-mail Notification
        emailext recipientProviders: [developers()], subject: "Job '${JOB_NAME}' (${BUILD_NUMBER}) finished with result: ${currentBuild.currentResult}" , body: "The build #${BUILD_NUMBER} finished with status ${currentBuild.currentResult} and contains the logs attached.", attachLog: true

        // TODO MS Teams
        //office365ConnectorSend message: "<Your message>", status:"${RESULT}", webhookUrl:'<The connector webhook url>'
        
        // Clean workspace (remove files used for this build)
        cleanWs()
    }
}

// ----------------------------------------------------------------------------------
// Run a command and return the status code
// ----------------------------------------------------------------------------------
def commandStatus(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
		return bat(returnStatus: true, script: script);
    }
}

// ----------------------------------------------------------------------------------
// Run a command and return the output generated
// ----------------------------------------------------------------------------------
def commandOutput(script) {
    if (isUnix()) {
        return sh(returnStdout: true, script: script);
    } else {
		return bat(returnStdout: true, script: script);
    }
}
