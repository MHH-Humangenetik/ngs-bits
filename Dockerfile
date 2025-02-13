FROM ubuntu:24.04
ENV PATH=/opt/ngs-bits/bin:/bin:$PATH LANG=C.UTF-8 LC_ALL=C.UTF-8
# update ubuntu packages and install build dependencies
RUN apt-get update && \
    apt-get install -y \
    	git \
    	make \
    	g++ \
    	qtbase5-dev \
    	libqt5xmlpatterns5-dev \
    	libqt5sql5-mysql \
    	libqt5sql5-odbc \
    	libqt5charts5-dev \
    	libqt5svg5-dev \
    	python3 \
    	python3-matplotlib \
    	libbz2-dev \
    	liblzma-dev \
    	libcurl4 \
    	libcurl4-openssl-dev \
    	zlib1g-dev \
		ca-certificates \
		wget \
    	gnupg
# MSSQL in QT
RUN wget --no-check-certificate -qO - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" | tee /etc/apt/sources.list.d/mssql-release.list && \
	apt-get update && \
	ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev mssql-tools
# clone and build ngs-bits
RUN mkdir -p /opt
WORKDIR /opt
RUN git clone https://github.com/imgag/ngs-bits.git
WORKDIR /opt/ngs-bits
RUN git checkout 2025_01 && git submodule update --recursive --init
RUN make build_3rdparty
RUN make build_libs_release
RUN make build_tools_release
# cleanup build dependencies
WORKDIR /
RUN find /opt/ngs-bits -mindepth 1 -maxdepth 1 ! -name 'bin' -exec rm -rf {} +
RUN apt-get remove -y \
    	git \
    	make \
    	g++ \
    	qtbase5-dev \
    	libqt5xmlpatterns5-dev \
    	libqt5charts5-dev \
    	libqt5svg5-dev \
    	libbz2-dev \
    	liblzma-dev \
    	libcurl4 \
    	zlib1g-dev \
    	wget
RUN apt-get install -y \
    	libqt5network5 \
    	libqt5xml5 \
    	libqt5xmlpatterns5
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*