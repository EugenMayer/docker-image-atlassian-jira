build:
	docker pull bellsoft/liberica-openjre-debian:11
	docker build -t ghcr.io/eugenmayer/jira . --build-arg JIRA_VERSION=${VERSION}
