FROM mcr.microsoft.com/powershell:debian-11

RUN apt-get update \
  && apt-get install jq -y

WORKDIR /home/

COPY startup /home/
RUN chmod +x startup

CMD [ "sh", "-c", "sh startup" ]
