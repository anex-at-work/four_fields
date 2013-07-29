# four_fields

Logging in the DB without deleting fields

## Installation

In your Gemfile:
```ruby
gem 'four_fields', :git => 'git://github.com/anex-at-work/four_fields.git'
```

## Default additional fields

Four fields must be in yours models:

* start_at
* end_at
* creator_id
* destroyer_id

In your model:
```ruby
four_fields
# OR
four_fields :disable_update => true
```

## ... and more

see the tests

## Generators

When

```
rails generate four_fields MODEL
```

then generate migration with four fields. Do not forget run **rake db:migrate**