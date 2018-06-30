FROM postgres

ENV BACKUPS_PATH=/backups
ENV PGUSER=postgres
ENV PGPASS=password
ENV PGHOST=postgres
ENV PGPORT=5432

ADD		backup.sh /backup.sh

VOLUME [ "/backups" ]

ENTRYPOINT	["/backup.sh"]