require 'net/http'

class Comment < ApplicationRecord
  def self.read_it_in
    file = File.read("/Users/alanbrown/Work/apps/influ/reddit.json")
    subreddit_data = JSON.parse(file)

    Comment.parse subreddit_data

    true
  end

  def self.parse(subreddit_data)
    rea = lambda do |comment, parent_id=nil|
      begin
        username = comment['data']['author']

        user = User.find_or_create_by(name: username)

        input = {
          parent_comment_id: parent_id,
          user_id: user.id,
          child_count: 0
        }

        if new_comment = Comment.create(input)
          user.increment! :comment_count
        end

        replies = comment['data']['replies']

        if replies
          children = replies['data']['children']

          if children.any?
            new_comment.update_attribute('child_count', children.count)

            children.each do |child|
              rea.call(child, new_comment.id)
            end
          end
        end
      rescue => e
        puts "e is #{e}"
      end
    end

    subreddit_data[0]['data']['children'].each do |h|
      rea.call(h)
    end


    subreddit_data[1]['data']['children'].each do |h|
      rea.call(h)
    end

  end

end
