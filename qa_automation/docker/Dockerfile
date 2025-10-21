# Use the official Python image from the Docker Hub with Debian Bullseye
FROM python:3.10-bullseye

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    gnupg \
    git \
    wget \
    apt-utils \
    zip \
    unzip \
    groff \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libcurl4 \
    libdbus-1-3 \
    libdrm2 \
    libexpat1 \
    libgbm1 \
    libgl1-mesa-dev \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libvulkan1 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    libxss1

# Download and install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws/

 # Download Google Chrome
 RUN curl -s "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" | jq -r '.channels.Stable.downloads.chrome[] | select(.platform == "linux64") | .url' > chrome_url.txt && \
 wget -O chrome.zip $(cat chrome_url.txt) && \
 rm -rf ./chrome-linux64 && \
 unzip chrome.zip && \
 chmod +x ./chrome-linux64/chrome        

# Download chromedriver
RUN curl -s "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" | jq -r '.channels.Stable.downloads.chromedriver[] | select(.platform == "linux64") | .url' > chromedriver_url.txt && \
 wget -O chromedriver.zip $(cat chromedriver_url.txt) && \
 rm -rf ./chromedriver-linux64 && \
 unzip chromedriver.zip && \
 chmod +x ./chromedriver-linux64/chromedriver

# Add chrome and chromedriver into $PATH
ENV PATH "$PWD/chrome-linux64:$PWD/chromedriver-linux64:$PATH"

# Clean up APT when done
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*