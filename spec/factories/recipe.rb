FactoryBot.define do
  factory :recipe do
    title { 'Buffalo Chicken and Ranch Wraps' }
    ingredients { ["1 pound thin-sliced bacon", "2 tablespoons bacon drippings", "3 pounds skinless, boneless chicken breast halves, cut into bite size pieces", "¼ cup Buffalo wing sauce", "2 tablespoons butter, melted", "12 (10 inch) flour tortillas", "1 cup diced fresh tomato", "¾ cup ranch dressing, divided"] }
    prep_time { 20 }
    cook_time { 40 }
    rating { 4.2 }
    image_link { 'somelink' }
    author { 'anans' }
    category {  create(:category) }
  end
end
