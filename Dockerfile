FROM mcr.microsoft.com/powershell:debian-11

RUN apt-get update \
  && apt-get install jq -y \
  && apt-get install git -y

WORKDIR /home/

COPY startup /home/
RUN chmod +x startup

ENV MSSQL=mssql

CMD [ "sh", "-c", "sh startup" ]
