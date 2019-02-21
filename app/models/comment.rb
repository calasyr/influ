require 'net/http'

class Comment < ApplicationRecord
  def self.read_it_in
    file = File.read("/Users/alanbrown/Work/apps/influ/reddit.json")
    data = JSON.parse(file)

    Comment.parse data
  end

  def self.parse(obj)
    rea = lambda do |comment, parent_id=nil|
      begin
        username = comment['data']['author']

        user = User.find_by_name(username)

        if user.nil?
          user = User.create(name: username)
        end

        input = {
          parent_comment_id: parent_id,
          user_id: user.id,
          child_count: 0
        }

        new_comment = Comment.create(input)

        replies = comment['data']['replies']

        if replies && replies['data']['children'].any?
          children = replies['data']['children']

          new_comment.update_attribute('child_count', children.count)

          children.each do |child|
            rea.call(child, new_comment.id)
          end
        end
      rescue => e
        puts "e is #{e}"
      end
    end

    obj[0]['data']['children'].each do |h|
      rea.call(h)
    end


    obj[1]['data']['children'].each do |h|
      rea.call(h)
    end

  end

end
