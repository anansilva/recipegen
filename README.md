# RecipeGen

(Add url from heroku)

## 1. Problem definition

> It's dinner time ! Create an application that helps users find the most relevant recipes that they can prepare with the ingredients that they have at home

### 1.1. How can we define relevancy?

Detailed specs for relancy are not provided so I defined it myself based on two criteria:

- What I would like to experience as an actual user
- Recipe and Ingredient metadata provided by the scrapped dataset

1. I want to see recipes that match all the searched ingredients first 
2. Within the best matches, I want to see those that have fewer extra ingredients that I did not searched for
3. If there are ties, show me the ones with better ranking
4. If there are ties in the ranking, show me the ones that take less time to cook and prep

### 1.2. User stories

As a user I can: 

- Search for recipes based on ingredients I have at home
- See the list of recipes ranked by relevance (defined on the previous section)

## 2. Tech stack

**Backend**: Rails 7, PostgresSQL

**Frontend**: Rails 7 (Hotwire), Bootstrap

**Devops**: Github (CI/CD), Heroku, Docker

## 3. Database

<img width="618" alt="Screenshot 2024-10-01 at 12 30 51" src="https://github.com/user-attachments/assets/cae71a53-a242-4975-89c9-18c15f5ab9ae">

Simple DB with a main `recipes` table with two `belongs_to` (optional) relationships with `categories` and `cuisines`. 

I later discovered that cuisine data values were not fed into the scrapped dataset so this table is empty for the current data.

Given the unstructured and random nature of the ingredient strings of the dataset, extracting a standardized list of ingredient names would require a complex and prone to error parsing setup. So I opted for a denormalized approach and saved the `ingredients` as an array of text directly in the `recipes` table.

This implies pushing the complexity to the query side, so the next step would be to define if I'd go with pattern matching or full text search. 

## 4. System architecture


## 5. Problems and mitigations

### 5.1. Denormalization vs Normalization

### 5.2 Performance 

### 5.3 Search constraints 

## Deployment Architecture: 

CI/CD pipeline automated with Github actions. 

Once pushed to main branch, the code goes through tests, code linting and security checks. 

If all stages pass, then code will be push to heroku. 

## Testing: 
Query and request tests using rspec. 

0. `make tdd` (if using docker)
1. `bundle exec rspec spec`


## Running the localy:

