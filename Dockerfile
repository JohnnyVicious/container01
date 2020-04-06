FROM mcr.microsoft.com/powershell:debian-11

RUN apt-get update \
  && apt-get install jq -y

WORKDIR /home/

COPY startup.ps1 /home/
RUN chmod +x startup.ps1

CMD [ "sh", "-c", "pwsh startup.ps1" ]
