require 'json'
require 'uri'
require 'cgi'

file_path = Rails.root.join('db', 'data', 'recipes-en.json')
file = File.read(file_path)
recipes_data = JSON.parse(file)

# decoding because using the proxy url is not working
def decode_url(proxy_url)
  return unless proxy_url.present?
  return proxy_url if proxy_url == 'https://www.allrecipes.com/img/misc/og-default.png'

  uri = URI.parse(proxy_url)

  query_params = URI.decode_www_form(uri.query).to_h
  encoded_image_url = query_params['url']

  return unless encoded_image_url.present?

  # Decode the inner image URL
  decoded_image_url = CGI.unescape(encoded_image_url)
end

puts 'Clearing existing data...'
Recipe.delete_all
Category.delete_all
Cuisine.delete_all

puts 'Creating recipes, categories and cuisines...'
recipes_data.each do |recipe_data|
  category_name = recipe_data['category']
  category = category_name.present? ? Category.create!(name: category_name) : nil

  cuisine_name = recipe_data['cuisine']
  cuisine = cuisine_name.present? ? Cuisine.create!(name: cuisine_name) : nil

  recipe = Recipe.create!(
    title: recipe_data['title'],
    cook_time: recipe_data['cook_time'],
    prep_time: recipe_data['prep_time'],
    rating: recipe_data['ratings'],
    ingredients: recipe_data['ingredients'],
    category:,
    cuisine:,
    author: recipe_data['author'],
    image_link: decode_url(recipe_data['image'])
  )
end

puts 'Seeding completed successfully!'
puts "Created #{Recipe.count} recipes, #{Category.count} categories and #{Cuisine.count} cuisines."
