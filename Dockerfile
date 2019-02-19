# escape=`
FROM microsoft/windowsservercore:ltsc2016 AS downloader
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG CLAM_VERSION="0.101.1"
ENV CLAM_HOME="C:\ClamAV" `
    CLAM_ROOT_URL="https://www.clamav.net/downloads/production/clamav-"

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest "https://www.clamav.net/downloads/production/clamav-0.101.1-win-x64-portable.zip" -OutFile 'clamav.zip' -UseBasicParsing; `
    Expand-Archive clamav.zip -DestinationPath $env:CLAM_HOME ;

# ClamAV
FROM microsoft/nanoserver:sac2016

ENV ClamPath "C:/Program Files/ClamAV-x64"

RUN mkdir logs; `
    mkdir db;

WORKDIR ${ClamPath}
COPY --from=downloader C:\ClamAV\ .

COPY clamd.conf .
COPY freshclam.conf .

RUN freshclam

EXPOSE 3310
ENTRYPOINT [ "clamd" ]