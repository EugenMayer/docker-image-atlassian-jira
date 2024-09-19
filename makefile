build:
	docker pull bellsoft/liberica-openjre-debian:17
	docker build -t ghcr.io/eugenmayer/jira . --build-arg JIRA_VERSION=${VERSION}

build11:
	docker pull bellsoft/liberica-openjre-debian:11
	docker build -t ghcr.io/eugenmayer/jira:${VERSION} -f Dockerfile_java11 --build-arg JIRA_VERSION=${VERSION} .
