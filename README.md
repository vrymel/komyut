## About

This is a personal project that involves me learning Elixir and Dijkstra's path-finding algorithm. 

There are two main features right now:

* **Jeepney route search** - users can specify two points within the city, and the it will return the shortest jeepney route(s) to take.
* **Jeepney route listing** - users can view jeepney routes within the city.

### Jeepney Route

In the Philippines, a [Jeepney](https://en.wikipedia.org/wiki/Jeepney) is a commonly used public transport. They have defined routes within the city so people can access different areas within the city by taking a single or multiple routes of a jeepney.

![Jeepney route search](https://raw.githubusercontent.com/vrymel/waypoints_direct/master/readme_imgs/jeepney.JPG "Jeepney route search")

## Screenshots

#### Jeepney route search

![Jeepney route search](https://raw.githubusercontent.com/vrymel/waypoints_direct/master/readme_imgs/route-search.jpg "Jeepney route search")

#### Jeepney route listing

![Jeepney route search](https://raw.githubusercontent.com/vrymel/waypoints_direct/master/readme_imgs/route-listing.jpg "Jeepney route search")

## Project Structure

The application code is setup to run directly on the host machine. The database layer is the only component hosted in docker for ease of installation.

#### Requirements
The following are the requirements for the application environment. See `user_data.txt` for the installation commands.

1. Erlang and Elixir
1. Node 6.12.x
1. Docker and Docker Compose (only used for the database)
1. Mix hex/phoenix
1. PostgreSQL (as a docker image)

## Deployment

#### <a id="deploy-box">Deploying in a new box</a>

1. Clone the application
1. Create the following directories and `.env` file:
    - `./database_docker_volume`
    - `./database_dumps`
    - `./.env`
1. (When needed) If there's a database dump for the application to use, make sure to uncomment `docker-entrypoint-initdb.d` in `docker-compose.yml` so the application will be preloaded with the dump database in `./database_dumps`.
    > This should be done only for the initial docker image build so make sure to comment the `docker-entrypoint-initdb.d` again on succeeding deployments.
1. Run the database containers
    
    `docker-compose up -d`

1. Install phoenix dependencies

    `./run_app_init.sh`

1. Run the server

    `./run_phxserver.py --detached`

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