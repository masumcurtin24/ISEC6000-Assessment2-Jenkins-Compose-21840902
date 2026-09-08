# Fixed Jenkins LTS release for repeatable builds
FROM jenkins/jenkins:2.568.3-jdk21

# Root is used temporarily to install trusted packages
USER root

# Install the Docker client used to communicate with Docker-in-Docker
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker-ce-cli \
        docker-buildx-plugin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install plugins required for pipelines, Docker, credentials, tests and logs
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator \
    docker-workflow \
    git \
    credentials-binding \
    junit \
    pipeline-stage-view \
    warnings-ng \
    ws-cleanup

# Run Jenkins using its non-root account
USER jenkins
