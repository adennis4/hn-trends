class PostsController < ApplicationController
  expose(:query) { params[:q] }
  expose(:post) { Post.new params.except 'action', 'controller' }
  expose(:chart_data) { post.results }
end
