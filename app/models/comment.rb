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
      new_comment = Comment.new(comment['data'], parent_id)
      return if comment['data']['children'].nil?
      comment['data']['children'].each do |child|
        rea.call(child, new_comment.id)
      end
    end

    obj.each do |h|
      rea.call(h)
    end
  end


  def self.initialize(hash, parent_id=nil)

    # save to db based on comment keys
  end
end
