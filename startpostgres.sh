docker run \
    --name fbd202502 \
    --rm \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD=Postgres123 \
    -e POSTGRES_DB=fbd202502 \
    -p 5432:5432 \
    -v $PWD/postgres-data:/var/lib/postgresql/ \
    -it \
    -d postgres


