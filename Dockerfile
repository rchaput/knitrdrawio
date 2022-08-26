FROM rocker/r-base:latest
# This Dockerfile is inspired from rocker/r-rmd, unfortunately not updated
# https://github.com/rocker-org/rocker/blob/master/r-rmd/Dockerfile

# We remove original labels (vendor, authors) to avoid looking like this
# project is endorsed/supported by Rocker.
LABEL org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.base.name="rocker/r-base:latest" \
      org.opencontainers.image.vendor="" \
      org.opencontainers.image.authors="Remy Chaput <rchaput.pro@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive

# Versions to install
ENV DRAWIO_VERSION="20.2.3"

# Install system dependencies
# libdrm2, libgbm1, libasound2, xvfb are required for drawio
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
                ghostscript \
                lmodern \
                pandoc-citeproc \
                qpdf \
                r-cran-formatr \
                r-cran-ggplot2 \
                r-cran-knitr \
                r-cran-rmarkdown \
                r-cran-runit \
                r-cran-testthat \
                texinfo \
                texlive-fonts-extra \
                texlive-fonts-recommended \
                texlive-latex-extra \
                texlive-latex-recommended \
                texlive-luatex \
                texlive-plain-generic \
                texlive-science \
                texlive-xetex \
                libdrm2 \
                libgbm1 \
                libasound2 \
                xvfb \
        && install.r binb linl pinp tint \
        && mkdir ~/.R \
        && echo _R_CHECK_FORCE_SUGGESTS_=FALSE > ~/.R/check.Renviron \
        && cd /usr/local/bin \
        && ln -s /usr/lib/R/site-library/littler/examples/render.r .

# Install draw.io
RUN wget -q -O drawio.deb https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/drawio-amd64-${DRAWIO_VERSION}.deb && \
    apt-get install -y --no-install-recommends ./drawio.deb && \
    rm -rf ./drawio.deb

# Install knitrdrawio (without args, `install.r` installs the local source package)
RUN install.r

CMD ["bash"]
