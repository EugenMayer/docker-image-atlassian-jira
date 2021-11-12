release: build push

build:
	docker pull bellsoft/liberica-openjre-debian:8
	docker pull bellsoft/liberica-openjre-debian:11
	source ./version && docker build -t ghcr.io/eugenmayer/jira . --build-arg JIRA_VERSION=$${VERSION}

push: tag-docker-hub tag-github push-github push-hub
	echo "done pushing"

push-github:
	docker push ghcr.io/eugenmayer/jira
	source ./version && docker push ghcr.io/eugenmayer/jira:$${VERSION}

push-hub:
	docker push eugenmayer/traefik:2.x
	source ./version && docker push eugenmayer/jira:en-$${VERSION}
	source ./version && docker push eugenmayer/jira:$${VERSION}

tag-docker-hub:
	source ./version && docker tag ghcr.io/eugenmayer/jira eugenmayer/jira:en-"$${VERSION}"
	source ./version && docker tag ghcr.io/eugenmayer/jira eugenmayer/jira:"$${VERSION}"
	source ./version && docker tag ghcr.io/eugenmayer/jira eugenmayer/jira

tag-github:
	source ./version && docker tag ghcr.io/eugenmayer/jira ghcr.io/eugenmayer/jira:"$${VERSION}"
