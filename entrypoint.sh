#!/bin/bash

set -u

function parseInputs(){
	# Required inputs
	if [ "${INPUT_CDK_SUBCOMMAND}" == "" ]; then
		echo "Input cdk_subcommand cannot be empty"
		exit 1
	fi
}

function installTypescript(){
	npm install typescript
}

function installAwsCdk(){
	echo "Install aws-cdk ${INPUT_CDK_VERSION}"
	if [ "${INPUT_CDK_VERSION}" != "latest" ]; then
		if [ "${INPUT_DEBUG_LOG}" == "true" ]; then
			npm install -g aws-cdk@${INPUT_CDK_VERSION}
		else
			npm install -g aws-cdk@${INPUT_CDK_VERSION} >/dev/null 2>&1
		fi

		if [ "${?}" -ne 0 ]; then
			echo "Failed to install aws-cdk ${INPUT_CDK_VERSION}"
		else
			echo "Successful install aws-cdk ${INPUT_CDK_VERSION}"
		fi
	fi
}

function installPipRequirements(){
	if [ -e "requirements.txt" ]; then
		echo "Install requirements.txt"
		if [ "${INPUT_DEBUG_LOG}" == "true" ]; then
			pip install -r requirements.txt
		else
			pip install -r requirements.txt >/dev/null 2>&1
		fi

		if [ "${?}" -ne 0 ]; then
			echo "Failed to install requirements.txt"
		else
			echo "Successful install requirements.txt"
		fi
	fi
}

function runCdk(){
  cdk --version
  node --version
  npm --version
  user=$(stat -c "%u" node_modules)
  group=$(stat -c "%g" node_modules)
  echo "User = $user"
  echo "Group = $group"
  addgroup -g $group github
  adduser -u $user -G github -D github
  mkdir -p cdk.out
  chown github:github cdk.out
  echo "Before deleting directory"
  ls -lt
  rm -rf node_modules
  echo "After deleting directory"
  ls -lt
  npm ci
  echo "After running npm ci"
  ls -lt
	echo "Run cdk ${INPUT_CDK_SUBCOMMAND} ${*} \"${INPUT_CDK_STACK}\""
	set -o pipefail
	cdk ${INPUT_CDK_SUBCOMMAND} ${*} "${INPUT_CDK_STACK}" 2>&1 | tee output.log
	exitCode=${?}
	set +o pipefail
	echo ::set-output name=status_code::${exitCode}
	ls -lt
	whoami
	echo "test" > cdk.out/test.txt
	cat cdk.out/test.txt
	echo "cdk contents:"
	ls -lt cdk.out
	cat cdk.out/tree.json
	output=$(cat output.log)
	echo "hi" > cdk.out/hi
  ls -lt cdk.out/*

	commentStatus="Failed"
	if [ "${exitCode}" == "0" ]; then
		commentStatus="Success"
	elif [ "${exitCode}" != "0" ]; then
		echo "CDK subcommand ${INPUT_CDK_SUBCOMMAND} for stack ${INPUT_CDK_STACK} has failed. See above console output for more details."
		exit 1
	fi

	if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${INPUT_ACTIONS_COMMENT}" == "true" ]; then
		commentWrapper="#### \`cdk ${INPUT_CDK_SUBCOMMAND}\` ${commentStatus}
<details><summary>Show Output</summary>

\`\`\`
${output}
\`\`\`

</details>

*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Working Directory: \`${INPUT_WORKING_DIR}\`*"

		payload=$(echo "${commentWrapper}" | jq -R --slurp '{body: .}')
		commentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)

		echo "${payload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${commentsURL}" > /dev/null
	fi
}

function main(){
	parseInputs
	cd ${GITHUB_WORKSPACE}/${INPUT_WORKING_DIR}
	installTypescript
	installAwsCdk
	installPipRequirements
	runCdk ${INPUT_CDK_ARGS}
}

main
