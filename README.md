# RecipeGen

Simply enter the ingredients you have on hand, and RecipeGen will instantly recommend delicious recipes tailored to your ingredients!

[**Try here!**](https://recipegen-9adbb5478cf7.herokuapp.com/)

## 1. Problem definition

> It's dinner time ! Create an application that helps users find the most relevant recipes that they can prepare with the ingredients that they have at home

### 1.1. How can we define relevancy?

Since detailed specifications for relevance were not provided, I established my own based on two key factors:

- **User Experience**: What I would personally like to experience as an actual user.
- **Available Metadata**: The recipe and ingredient metadata extracted from the scraped dataset.

1. **Exact Ingredient Match**: Recipes that contain all of the searched ingredients should be prioritized at the top of the results.
2. **Minimal Extra Ingredients**: Among the top results, prioritize recipes that have the fewest additional ingredients beyond those searched for.
3. **Higher User Ratings**: If multiple recipes match both the searched and extra ingredient criteria, rank them by user rating, with higher-rated recipes appearing first.
4. **Shorter Prep and Cook Time**: In case of a tie in ratings, show recipes that require the least preparation and cooking time.

### 1.2. User stories

As a user I can: 

- Search for recipes based on the ingredients I have at home.
- View a list of recipes ranked by relevance, as defined in the previous section.

## 2. Tech stack

**Backend**: Rails 7, PostgresSQL

**Frontend**: Rails 7 (Hotwire), Bootstrap

**Devops**: Github (CI/CD), Heroku, Docker

## 3. Database

<img width="618" alt="Screenshot 2024-10-01 at 12 30 51" src="https://github.com/user-attachments/assets/cae71a53-a242-4975-89c9-18c15f5ab9ae">

I designed a simple database structure with a main `recipes` table that includes two optional `belongs_to` relationships: one with `categories` and another with `cuisines`.

(Note: I later discovered that the `cuisines` table remains empty for now, as the scraped dataset didn’t contain any cuisine data.)

Due to the inconsistent and random nature of the ingredient strings in the dataset, extracting a standardized list of ingredient names would require complex parsing logic, which is both error-prone and difficult to manage. Instead, I opted for a denormalized approach by storing the ingredients as an array of text directly within the recipes table.

This approach shifts the complexity to the query side. The next step was to decide whether to use pattern matching or full-text search. Initially, I implemented a simple pattern-matching solution using `ILIKE`, which provided decent results in terms of both accuracy and performance.

However, things became more complicated when I introduced pluralization/singularization logic (e.g., searching for "tomatoes" should return recipes containing "tomato"). As the number of rules increased, so did the code complexity and the risk of bugs, particularly with edge cases.

At this point, I decided to switch to full-text search, which ultimately became my final solution (details on that below).

## 4. System architecture

![image](https://github.com/user-attachments/assets/35a47c4f-a800-4de2-988b-f7009a417546)

Single page application that updates the view with recipe cards once a search is submitted. 

Query logic is isolated in a Query Object `RecipeQuery`.

## 5. Problems, mitigations and other considerations

### 5.1. Denormalization vs Normalization

I considered storing the `ingredients` column in a separate `ingredients` table instead of a column within the recipes table. However, given the current scope, this wouldn't provide any real benefit. At this stage, and with the dataset as it is, I'm not concerned about duplication. Additionally, having a separate table would introduce an extra `.joins` in my queries, adding unnecessary complexity.

### 5.2 Performance 

- `ILIKE` performed well for the dataset size and pagination, even without any indexing.
- Full-text search, while noticeably slower (even with pagination), improved significantly after adding indexing and an `ingredients_tsvector` column, though this does introduce some additional overhead.

### 5.3. Search 

The code includes tests that assess both the search results and ranking. I found that these tests revealed almost no significant difference between `ILIKE` and full-text search. However, there was a slight improvement in ranking when I prioritized ingredient matches before applying the relevance ranking from `ts_rank`. While `ts_rank` did negatively impact the scores of recipes with long ingredient lists, it still did not yield the best results overall. Additionally, term frequency is not always a reliable indicator of the best recipes based on the entire list of selected ingredients. Consequently, I opted to incorporate the number of matched ingredients before utilizing `ts_rank`.

Looking ahead, I see several opportunities for improving the search functionality. For example, a search for "milk" currently returns results for "coconut milk," which is not a direct match for the requested ingredient.

I would also like to explore strategies for handling typos and similarities, such as matching 'tomoto' or 'tomta' to 'tomato.' Implementing a fuzzy search using PostgreSQL's pg_trgm extension could be an effective solution, although we should be cautious of potential unintended side effects.

I would also consider implementing features such as filtering by category and author, allowing users to click on a recipe's category and view other related recipes that align with their chosen ingredients.

Another interesting enhancement could involve assigning greater weight to perishable ingredients, ensuring that recipes utilizing these ingredients are prioritized, helping users make the most of their fresh produce.

### 5.4.Final Thoughts

It was an awesome exercise where I got to build something I can see myself using while exploring various text search options.

Considering everything, if this were a minimum viable product (MVP), I would likely have opted for the pattern matching solution first. It’s simple and straightforward, allowing for a quick launch and rapid user feedback.

For a more robust and scalable solution, I ultimately decided to implement full-text search, which I have chosen to keep.

## Deployment Architecture: 

CI/CD pipeline automated with Github actions. 

Once pushed to main branch, the code goes through tests, code linting and security checks. 

If all stages pass, then code will be push to heroku. 

## Running the locally (using docker):

0. `make setup`
1. `make server`

## Testing: 
Query and request tests using rspec. 

0. `make tdd` (using docker)
1. `bundle exec rspec spec`




