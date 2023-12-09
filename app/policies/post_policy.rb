class PostPolicy < ApplicationPolicy
  def all?
    raise Pundit::NotAuthorizedError, "You are not authorized to see all posts" unless @user&.admin?
    true
  end

  def update?
    raise Pundit::NotAuthorizedError, "You are not authorized to update this post" unless @user == @record.user || @user&.admin?
    true
  end

  def destroy?
    raise Pundit::NotAuthorizedError, "You are not authorized to delete this post" unless @user == @record.user || @user&.admin?
    true
  end
end
