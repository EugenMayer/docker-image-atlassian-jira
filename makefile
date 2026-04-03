build10:
	docker pull bellsoft/liberica-openjre-debian:17
	docker build -t ghcr.io/eugenmayer/jira -f Dockerfile_17 --build-arg JIRA_VERSION=${VERSION} .

build11:
	docker pull eclipse-temurin:21-noble
	docker build -t ghcr.io/eugenmayer/jira:${VERSION} -f Dockerfile --build-arg JIRA_VERSION=${VERSION} .
