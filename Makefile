args = $(filter-out $@, $(MAKECMDGOALS))

## Misc
list: # List all available targets for this Makefile
	@grep '^[^#[:space:]].*:' Makefile

# DEVELOPMENT
setup: # Copy configuration files locally needed for running Docker
	cp ./docker/config/database.sample.yml ./config/database.yml
up:
	docker-compose up
down:
	docker-compose down
build:
	docker-compose build --no-cache web
build.sidekiq:
	docker-compose build --no-cache sidekiq
bundle:
	docker-compose run --rm web bash -c "bundle"
bash:
	docker-compose run --rm web bash
console:
	docker-compose run --rm web bash -c "bin/rails console"
restart:
	docker-compose exec web bash -c "bundle exec rails restart"
rubocop: 
	docker-compose run --rm web bash -c "bundle exec rubocop -a"
server:
	docker-compose run \
        --rm \
        --service-ports \
        --use-aliases \
        web
frontend:
	docker-compose run web bash -c "rails dartsass:watch"
binding.pry:
	docker attach `docker-compose ps -q web`

# TDD
tdd:
	docker-compose -f docker-compose.tdd.yml run --rm tdd && \
		docker-compose -f docker-compose.tdd.yml down