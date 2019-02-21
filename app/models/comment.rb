require 'net/http'

class Comment < ApplicationRecord
  def self.read_it_in
    file = File.read("/Users/alanbrown/Work/apps/influ/reddit.json")
    data = JSON.parse(file)

    Comment.parse data
  end

  def self.get_it_all
    uri = URI.parse("https://www.reddit.com/r/NetflixBestOf/comments/7p8s2b/us_the_prestige_2006_desperate_to_reveal_each.json")

    request = Net::HTTP::Get.new(uri.request_uri)

    Comment.parse(api_request(request, uri))
  end

  def self.api_request(request, uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)

    JSON.parse(response.body)
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
          user_id: user.id
        }
        new_comment = Comment.create(input)

        # puts comment['data']['replies']['data']['children']

        # binding.pry
        puts "new_comment.id is #{new_comment.id}"

        replies = comment['data']['replies']
        if replies && replies['data']['children'].any?
          replies['data']['children'].each do |child|
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
