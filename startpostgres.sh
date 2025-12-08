docker run \
    --name fbd20252 \
    --rm \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD=Postgres123 \
    -e POSTGRES_DB=fbd20252 \
    -p 5432:5432 \
    -v $PWD/postgres-data:/var/lib/postgresql/ \
    -v $PWD/csv_dados:/var/lib/csv_dados/ \
    -it \
    -d postgres


