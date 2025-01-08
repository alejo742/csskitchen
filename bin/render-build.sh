set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# because i have a free instance and can't migrate pre-start
bundle exec rails db:drop
bundle exec rails db:create
bundle exec rails db:migrate