set -o errexit

bundle install
RAILS_ENV=production bundle exec rails assets:clean
RAILS_ENV=production bundle exec rails assets:precompile
bundle exec rails db:migrate