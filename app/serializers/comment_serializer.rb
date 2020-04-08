class CommentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :body, :mentioned_usernames, :created_at, :updated_at, :parent_id, :parent_author_name, :versions_count

  has_one :author, serializer: UserSerializer, root: :users
  has_one :discussion, serializer: DiscussionSerializer
  has_many :likers, serializer: UserSerializer, root: :users
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments

  def parent_author_name
    object.parent.author_name if object.parent
  end

  def include_comment_relations?
    !Hash(scope)[:skip_comment_relations]
  end
  alias :include_mentioned_usernames? :include_comment_relations?
  alias :include_likers?              :include_comment_relations?
  alias :include_attachments?         :include_comment_relations?

end
