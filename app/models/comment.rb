class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, foreign_key: "post_id"
  validates :user_id, :post_id, :content, presence: true

  serialize :recipient_ids, Array

  def self.recent_comments recent_comment_id, post_id
    comments = self.where("post_id = ?", post_id).includes(:user).select("id, content, user_id, created_at").order("created_at DESC")
    comments = comments.where("id > ?", recent_comment_id) if recent_comment_id.present? && recent_comment_id != "undefined"
    comments
  end

  def save_and_mail(user)
    post = self.post
    post_owner = post.user
    self.save
    #UserMailer.delay.comment_mail_to_owner(post_owner, user, post, self) if post_owner.id != user.id
    UserMailer.comment_mail_to_owner(post_owner, user, post, self).deliver if post_owner.id != user.id
    self.recipient_ids.each do |uid|
      next if uid.to_i == post_owner.id
      u = User.select("id, email, first_name, last_name").find_by_id(uid)
      #UserMailer.delay.comment_mail(post_owner, user, post, self, u).deliver
      UserMailer.comment_mail(post_owner, user, post, self, u).deliver
    end
  end

end
