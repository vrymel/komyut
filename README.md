## Project Structure

The application code is setup to run directly on the host machine. The database layer is the only component hosted in docker for ease of installation.

#### Requirements
The following are the requirements for the application environment. See `user_data.txt` for the installation commands.

1. Erlang and Elixir
1. Node 6
1. Docker and Docker Compose (only used for the database)
1. Mix hex/phoenix
1. PostgreSQL (as a docker image)

## Deployment in a Docker environment

#### <a id="deploy-box">Deploying on a new box</a>

1. Clone the application
1. Create the following directories and `.env` file:
    - `./database_docker_volume`
    - `./database_dumps`
    - `./.env`
1. (When needed) If there's a database dump for the application to use, make sure to uncomment `docker-entrypoint-initdb.d` in `docker-compose.yml` so the application will be preloaded with the dump database in `./database_dumps`.
    > This should be done only for the initial docker image build so make sure to comment the `docker-entrypoint-initdb.d` again on succeeding deployments.
1. Run the database containers
    
    `docker-compose up -d`

1. Run the server

    `./run_phxserver.py`

    > This helper script just retrieves the environment variables defined in `.env` and prepend it as flags when running `mix phx.server`. So it is important that `.env`'s is targeting development or production.

    > If the application can't connect to the database layer. Run this command with `sudo`.

#### Succeeding deployments

Since the application code is running locally. Updating is as easy as pulling from the remote repo.

    git fetch --all && git pull origin master

If replacing the database do:

1. Kill the docker database container.

    `docker-compose down`

1. Delete and recreate directory `database_docker_volume`

1. Repeat step 3 in the [deployment steps](#deploy-box).