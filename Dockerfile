FROM mcr.microsoft.com/powershell:debian-11

RUN apt-get update \
  && apt-get install jq -y \
  && apt-get install git -y

WORKDIR /home/

COPY startup /home/
RUN chmod +x startup

ENV MSSQL=mssql
ENV MSSQLPORT=1433
ENV SQLER=sqler
ENV SQLERPORT=8025

CMD [ "sh", "-c", "sh startup" ]
