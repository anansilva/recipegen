# RecipeGen

(Add url from heroku)

## Tech stack

Backend: Rails 7, PostgresSQL
Frontend: Rails 7 (Hotwire), Bootstrap
Devops: Github, Heroku, Docker


## User stories

As a user I can: 

- Search for recipes based on ingredients I have at home
- See the list of recipes ranked by relevance (number of matching ingredients in recipe + recipe rating + total cooking time)

## Database

## System architecture

## Deployment Architecture: 
CI/CD pipeline automated with Github actions. Once pushed to main branch, the code goes through tests, code linting and security checks. If all stages pass, then code will be push to heroku. 

## Testing: 
Query and request tests using rspec. 

0. `make tdd` (if using docker)
1. `bundle exec rspec spec`


## Running the localy:

