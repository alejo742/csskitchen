require 'securerandom'

# create seed user
user = User.create!(
    first_name: 'Seed',
    last_name: 'User',
    email: 'seeduser@example.com',
    provider: 'none',
    uid: SecureRandom.uuid
)

# create seed challenges
Challenge.create!([
  {
    title: 'Spaghetti Carbonara',
    description: 'Create a classic Italian Spaghetti Carbonara with a creamy sauce and crispy pancetta.',
    tags: ['Italian', 'Pasta', 'Dinner'],
    difficulty: 'easy',
    user: user
  },
  {
    title: 'Vegan Buddha Bowl',
    description: 'Prepare a nutritious and colorful Vegan Buddha Bowl with quinoa, roasted vegetables, and tahini dressing.',
    tags: ['Vegan', 'Healthy', 'Lunch'],
    difficulty: 'medium',
    user: user
  },
  {
    title: 'Beef Wellington',
    description: 'Master the art of making a perfect Beef Wellington with tender beef fillet wrapped in puff pastry.',
    tags: ['British', 'Meat', 'Dinner'],
    difficulty: 'hard',
    user: user
  },
  {
    title: 'Chocolate Soufflé',
    description: 'Bake a light and airy Chocolate Soufflé that rises beautifully and has a rich chocolate flavor.',
    tags: ['Dessert', 'Chocolate', 'Baking'],
    difficulty: 'easy',
    user: user
  },
  {
    title: 'Sushi Rolls',
    description: 'Roll your own Sushi with fresh fish, vegetables, and perfectly seasoned sushi rice.',
    tags: ['Japanese', 'Seafood', 'Dinner'],
    difficulty: 'medium',
    user: user
  }
])