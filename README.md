## Deployment in a Docker environment

### Initial deployment

1. Clone the application
1. Create the following directories and `.env` file:
    - `./database_docker_volume`
    - `./database_dumps`
    - `./.env`
1. If there is a database dump for the application to use, make sure to uncomment `docker-entrypoint-initdb.d` in `prod-docker-compose.yml` so application will be preloaded with the dump database in `./database_dumps`.
    - This should be done only for the initial docker image build so make sure to comment the `docker-entrypoint-initdb.d` again on succeeding deployments.
1. Run the application containers
    
    `docker-compose -f prod-docker-compose.yml up`

### Succeeding deployments

1. Stop the running docker containers

    `docker-compose -f prod-docker-compose.yml down`

1. Pull the application changes from remote

    `git fetch --all && git pull origin master`

1. Run the application containers again

    `docker-compose -f prod-docker-compose.yml up`