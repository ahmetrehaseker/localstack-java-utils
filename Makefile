ADDITIONAL_MVN_ARGS ?= -DskipTests -q

usage:           ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

build:           ## Build the code using Maven
	mvn -Pfatjar $(ADDITIONAL_MVN_ARGS) clean javadoc:jar source:jar package $(ADDITIONAL_MVN_TARGETS)

publish-maven:   ## Publish artifacts to Maven Central
	ADDITIONAL_MVN_TARGETS=deploy ADDITIONAL_MVN_ARGS="-DskipTests" make build

test-v1:
	USE_SSL=1 SERVICES=serverless,kinesis,sns,sqs,iam,cloudwatch mvn -Pawssdkv1 \
                 -DargLine="-javaagent:thundra-agent-bootstrap.jar"  -Dmaven.test.failure.ignore=true -Dtest="!cloud.localstack.awssdkv2.*Test, !cloud.localstack.docker.*Test" test

test-v2:
	USE_SSL=1 SERVICES=serverless,kinesis,sns,sqs,iam,cloudwatch mvn -Pawssdkv2 \
		 -DargLine="-javaagent:thundra-agent-bootstrap.jar"  -Dmaven.test.failure.ignore=true -Dtest="cloud.localstack.awssdkv2.*Test" test

test-v3:
	USE_SSL=1 SERVICES=serverless,kinesis,sns,sqs,iam,cloudwatch mvn -Pawssdkv1 \
		 -DargLine="-javaagent:thundra-agent-bootstrap.jar"  -Dmaven.test.failure.ignore=true -Dtest="cloud.localstack.docker.*Test" -DrunOrder=alphabetical test

test:            ## Run Java/JUnit tests for AWS SDK v1 and v2
	make test-v2
	make test-v1
	make test-v3

.PHONY: usage clean install test test-v1 test-v2
