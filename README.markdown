# Acts As Favable (aka Acts As Likeable)

[![Build Status](https://travis-ci.org/ryanto/acts_as_votable.png)](https://travis-ci.org/ryanto/acts_as_votable)

Acts As Votable is a Ruby Gem specifically written for Rails/ActiveRecord models.
The main goals of this gem are:

- Allow any model to be faved under arbitrary scopes.
  they can come from any model (such as a Group or Team).
- Provide an easy to write/read syntax.

## Installation

### Supported Ruby and Rails versions

* Ruby 1.8.7, 1.9.2, 1.9.3
* Ruby 2.0.0, 2.1.0
* Rails 3.0, 3.1, 3.2
* Rails 4.0, 4.1+

### Install

Just add the following to your Gemfile.

```ruby
gem 'acts_as_votable', '~> 0.10.0'
```

And follow that up with a ``bundle install``.

### Database Migrations

Acts As Votable uses a favs table to store all voting information.  To
generate and run the migration just use.

    rails g acts_as_favable:migration
    rake db:migrate

You will get a performance increase by adding in cached columns to your model's
tables.  You will have to do this manually through your own migrations.  See the
caching section of this document for more information.

## Usage

### Votable Models

```ruby 
class Post < ActiveRecord::Base
  acts_as_votable
end

@post = Post.new(:name => 'my post!')
@post.save

@post.liked_by @user
@post.favs_for.size # => 1
```

### Like/Dislike Yes/No Up/Down

Here are some voting examples.  All of these calls are valid and acceptable.  The
more natural calls are the first few examples.

```ruby
@post.liked_by @user1
@post.downvote_from @user2
@post.fav_by :fav => @user3
@post.fav_by :fav => @user4, :fav => 'bad'
@post.fav_by :fav => @user5, :fav => 'like'
```

By default all favs are positive, so `@user3` has cast a 'good' vote for `@post`.

`@user1`, `@user3`, and `@user5` all faved in favor of `@post`.

`@user2` and `@user4` on the other had has faved against `@post`.


Just about any word works for casting a vote in favor or against post.  Up/Down,
Like/Dislike, Positive/Negative... the list goes on-and-on.  Boolean flags `true` and
`false` are also applicable.

Revisiting the previous example of code.

```ruby
# positive favs
@post.liked_by @user1
@post.fav_by :fav => @user3
@post.fav_by :fav => @user5, :fav => 'like'

# negative favs
@post.downvote_from @user2
@post.fav_by :fav => @user2, :fav => 'bad'

# tally them up!
@post.favs_for.size # => 5
@post.get_likes.size # => 3
@post.get_upfavs.size # => 3
@post.get_dislikes.size # => 2
@post.get_downfavs.size # => 2
```

Active Record scopes are provided to make life easier.

```ruby
@post.favs_for.up.by_type(User)
@post.favs_for.down
@user1.favs.up
@user1.favs.down
@user1.favs.up.by_type(Post)
```

Once scoping is complete, you can also trigger a get for the
voter/votable

```ruby
@post.favs_for.up.by_type(User).voters
@post.favs_for.down.by_type(User).voters

@user.favs.up.for_type(Post).votables
@user.favs.up.votables
```

You can also 'unvote' a model to remove a previous vote.

```ruby
@post.liked_by @user1
@post.unliked_by @user1

@post.disliked_by @user1
@post.undisliked_by @user1
```

Unvoting works for both positive and negative favs.

### Examples with scopes

You can add a scope to your vote

```ruby
# positive favs
@post.liked_by @user1, :fav_scope => 'rank'
@post.fav_by :fav => @user3, :fav_scope => 'rank'
@post.fav_by :fav => @user5, :fav => 'like', :fav_scope => 'rank'

# tally them up!
@post.find_favs_for(:fav_scope => 'rank').size # => 5
@post.get_likes(:fav_scope => 'rank').size # => 3
@post.get_upfavs(:fav_scope => 'rank').size # => 3
@post.get_dislikes(:fav_scope => 'rank').size # => 2
@post.get_downfavs(:fav_scope => 'rank').size # => 2

# votable model can be faved under different scopes
# by the same user
@post.fav_by :fav => @user1, :fav_scope => 'week'
@post.fav_by :fav => @user1, :fav_scope => 'month'

@post.favs_for.size # => 2
@post.find_favs_for(:fav_scope => 'week').size # => 1
@post.find_favs_for(:fav_scope => 'month').size # => 1
```
### Adding weights to your favs

You can add weight to your vote. The default value is 1.

```ruby
# positive favs
@post.liked_by @user1, :fav_weight => 1
@post.fav_by :fav => @user3, :fav_weight => 2
@post.fav_by :fav => @user5, :fav => 'like', :fav_scope => 'rank', :fav_weight => 3

# negative favs
@post.downvote_from @user2, :fav_scope => 'rank', :fav_weight => 1
@post.fav_by :fav => @user2, :fav => 'bad', :fav_scope => 'rank', :fav_weight => 3

# tally them up!
@post.find_favs_for(:fav_scope => 'rank').sum(:fav_weight) # => 6
@post.get_likes(:fav_scope => 'rank').sum(:fav_weight) # => 6
@post.get_upfavs(:fav_scope => 'rank').sum(:fav_weight) # => 6
@post.get_dislikes(:fav_scope => 'rank').sum(:fav_weight) # => 4
@post.get_downfavs(:fav_scope => 'rank').sum(:fav_weight) # => 4
```

### The Voter

You can have your voters `acts_as_voter` to provide some reserve functionality.

```ruby
class User < ActiveRecord::Base
  acts_as_voter
end

@user.likes @article

@article.favs.size # => 1
@article.likes.size # => 1
@article.dislikes.size # => 0
```

To check if a voter has faved on a model, you can use ``faved_for?``.  You can
check how the voter faved by using ``faved_as_when_faved_for``.

```ruby
@user.likes @comment1
@user.up_favs @comment2
# user has not faved on @comment3

@user.faved_for? @comment1 # => true
@user.faved_for? @comment2 # => true
@user.faved_for? @comment3 # => false

@user.faved_as_when_faved_for @comment1 # => true, he liked it
@user.faved_as_when_faved_for @comment2 # => false, he didnt like it
@user.faved_as_when_faved_for @comment3 # => nil, he has yet to vote
```

You can also check whether the voter has faved up or down.

```ruby
@user.likes @comment1
@user.dislikes @comment2
# user has not faved on @comment3

@user.faved_up_on? @comment1 # => true
@user.faved_down_on? @comment1 # => false

@user.faved_down_on? @comment2 # => true
@user.faved_up_on? @comment2 # => false

@user.faved_up_on? @comment3 # => false
@user.faved_down_on? @comment3 # => false
```

Aliases for methods `faved_up_on?` and `faved_down_on?` are: `faved_up_for?`, `faved_down_for?`, `liked?` and `disliked?`.

Also, you can obtain a list of all the objects a user has faved for.
This returns the actual objects instead of instances of the Vote model.
All objects are eager loaded

```ruby
@user.find_faved_items

@user.find_up_faved_items
@user.find_liked_items

@user.find_down_faved_items
@user.find_disliked_items
```

Members of an individual model that a user has faved for can also be
displayed. The result is an ActiveRecord Relation.

```ruby
@user.get_faved Comment

@user.get_up_faved Comment

@user.get_down_faved Comment
```

### Registered favs

Voters can only vote once per model.  In this example the 2nd vote does not count
because `@user` has already faved for `@shoe`.

```ruby
@user.likes @shoe
@user.likes @shoe

@shoe.favs # => 1
@shoe.likes # => 1
```

To check if a vote counted, or registered, use `vote_registered?` on your model
after voting.  For example:

```ruby
@hat.liked_by @user
@hat.vote_registered? # => true

@hat.liked_by => @user
@hat.vote_registered? # => false, because @user has already faved this way

@hat.disliked_by @user
@hat.vote_registered? # => true, because user changed their vote

@hat.favs.size # => 1
@hat.positives.size # => 0
@hat.negatives.size # => 1
```

To permit duplicates entries of a same voter, use option duplicate. Also notice that this
will limit some other methods that didn't deal with multiples favs, in this case, the last vote will be considered.

```ruby
@hat.fav_by voter: @user, :duplicate => true
```

## Caching

To speed up perform you can add cache columns to your votable model's table.  These
columns will automatically be updated after each vote.  For example, if we wanted
to speed up @post we would use the following migration:

```ruby
class AddCachedfavsToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :cached_favs_total, :integer, :default => 0
    add_column :posts, :cached_favs_score, :integer, :default => 0
    add_column :posts, :cached_favs_up, :integer, :default => 0
    add_column :posts, :cached_favs_down, :integer, :default => 0
    add_column :posts, :cached_weighted_score, :integer, :default => 0
    add_column :posts, :cached_weighted_total, :integer, :default => 0
    add_column :posts, :cached_weighted_average, :float, :default => 0.0
    add_index  :posts, :cached_favs_total
    add_index  :posts, :cached_favs_score
    add_index  :posts, :cached_favs_up
    add_index  :posts, :cached_favs_down
    add_index  :posts, :cached_weighted_score
    add_index  :posts, :cached_weighted_total
    add_index  :posts, :cached_weighted_average

    # Uncomment this line to force caching of existing favs
    # Post.find_each(&:update_cached_favs)
  end

  def self.down
    remove_column :posts, :cached_favs_total
    remove_column :posts, :cached_favs_score
    remove_column :posts, :cached_favs_up
    remove_column :posts, :cached_favs_down
    remove_column :posts, :cached_weighted_score
    remove_column :posts, :cached_weighted_total
    remove_column :posts, :cached_weighted_average
  end
end
```

`cached_weighted_average` can be helpful for a rating system, e.g.: 

Order by average rating:

```ruby
Post.order(:cached_weighted_average => :desc)
```

Display average rating:

```erb
<%= post.weighted_average.round(2) %> / 5
<!-- 3.5 / 5 -->
```

## Testing

All tests follow the RSpec format and are located in the spec directory.
They can be run with:

```
rake spec
```

## Changes  

### Fixes for votable voter model  

In version 0.8.0, there are bugs for a model that is both votable and voter.  
Some name-conflicting methods are renamed:
+ Renamed Votable.favs to favs_for  
+ Renamed Votable.vote to fav_by,
+ Removed Votable.fav_by alias (was an alias for :fav_up)
+ Renamed Votable.unvote_for to unfav_by
+ Renamed Votable.find_favs to find_favs_for
+ Renamed Votable.up_favs to get_upfavs 
  + and its aliases :get_true_favs, :get_ups, :get_upfavs, :get_likes, :get_positives, :get_for_favs
+ Renamed Votable.down_favs to get_downfavs 
  + and its aliases :get_false_favs, :get_downs, :get_downfavs, :get_dislikes, :get_negatives


## License

Acts as votable is released under the [MIT
License](http://www.opensource.org/licenses/MIT).

## TODO

- Pass in a block of options when creating acts_as.  Allow for things
  like disabling the aliasing

- Smarter language syntax.  Example: `@user.likes` will return all of the votables
that the user likes, while `@user.likes @model` will cast a vote for @model by
@user.


- The aliased methods are referred to by using the terms 'up/down' and/or
'true/false'.  Need to come up with guidelines for naming these methods.

- Create more aliases. Specifically for counting favs and finding favs.
