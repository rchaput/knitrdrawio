FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG SYS_REQS="xvfb wget libgbm1 libasound2 r-base pandoc"
ENV DRAWIO_VERSION="16.0.0"

# Install system requirements
RUN apt update && apt install -y ${SYS_REQS}

# Install draw.io
RUN wget -q -O drawio.deb https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/drawio-amd64-${DRAWIO_VERSION}.deb && \
    apt install -y ./drawio.deb && \
    rm -rf ./drawio.deb

# Install dependencies to build the package
RUN R -q -e 'install.packages("devtools"); devtools::install_dev_deps(".")'

# Build and install the package
RUN R -q -e 'devtools::build(); devtools::install()'
