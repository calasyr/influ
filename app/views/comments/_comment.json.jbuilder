json.extract! comment, :id, :comment_id, :parent_comment_id, :user_id, :created_at, :updated_at
json.url comment_url(comment, format: :json)
