FROM untergeek/curator:7.0.1
WORKDIR /.curator
COPY curator.yml /.curator/curator.yml
COPY actionfile.yml /.curator/actionfile.yml
