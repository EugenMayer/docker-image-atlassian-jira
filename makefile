release: build tag-github push-github

release-dockerhub: build tag-docker-hub push-hub

build:
	docker pull bellsoft/liberica-openjre-debian:11
	source ./version && docker build -t ghcr.io/eugenmayer/jira . --build-arg JIRA_VERSION=$${VERSION}

push: tag-github push-github
	echo "done pushing to github"

build8:
	docker pull bellsoft/liberica-openjre-debian:8
	source ./version && docker build -t ghcr.io/eugenmayer/jira . --build-arg JIRA_VERSION=$${VERSION} -f Dockerfile_java8


push-github:
	docker push ghcr.io/eugenmayer/jira
	source ./version && docker push ghcr.io/eugenmayer/jira:$${VERSION}

push-hub:
	docker push eugenmayer/jira
	source ./version && docker push eugenmayer/jira:en-$${VERSION}
	source ./version && docker push eugenmayer/jira:$${VERSION}

tag-docker-hub:
	source ./version && docker tag ghcr.io/eugenmayer/jira eugenmayer/jira:en-"$${VERSION}"
	source ./version && docker tag ghcr.io/eugenmayer/jira eugenmayer/jira:"$${VERSION}"
	source ./version && docker tag ghcr.io/eugenmayer/jira eugenmayer/jira

tag-github:
	source ./version && docker tag ghcr.io/eugenmayer/jira ghcr.io/eugenmayer/jira:"$${VERSION}"
