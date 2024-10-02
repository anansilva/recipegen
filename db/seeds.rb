require 'json'
require 'uri'
require 'cgi'

file_path = Rails.root.join('db', 'data', 'recipes-en.json')
file = File.read(file_path)
recipes_data = JSON.parse(file)

# Decoding the proxy URL
def decode_url(proxy_url)
  return unless proxy_url.present?
  return proxy_url if proxy_url == 'https://www.allrecipes.com/img/misc/og-default.png'

  uri = URI.parse(proxy_url)
  query_params = URI.decode_www_form(uri.query).to_h
  encoded_image_url = query_params['url']

  return unless encoded_image_url.present?

  # Decode the inner image URL
  CGI.unescape(encoded_image_url)
end

puts 'Clearing existing data...'
start_time = Time.now
Recipe.delete_all
Category.delete_all
puts "Data cleared in #{Time.now - start_time} seconds."

puts 'Creating recipes, and categories...'
start_time = Time.now

categories = []
recipes = []

recipes_data.each do |recipe_data|
  category_name = recipe_data['category']
  categories << { name: category_name } if category_name.present? && !categories.map { |c| c[:name] }.include?(category_name)

  recipes << {
    title: recipe_data['title'],
    cook_time: recipe_data['cook_time'],
    prep_time: recipe_data['prep_time'],
    rating: recipe_data['ratings'],
    ingredients: recipe_data['ingredients'],
    author: recipe_data['author'],
    image_link: decode_url(recipe_data['image']),
    category: category_name
  }
end

Category.insert_all(categories) unless categories.empty?

categories_map = Category.all.index_by(&:name)

recipes.map do |recipe|
  recipe[:category_id] = categories_map[recipe[:category]].id if recipe[:category].present?
  recipe[:category_id] ||= nil
  recipe.except!(:category)
end

Recipe.insert_all(recipes)

puts "Seeding completed successfully in #{Time.now - start_time} seconds!"
puts "Created #{Recipe.count} recipes, and #{Category.count} categories."
