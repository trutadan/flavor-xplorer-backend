class CommentPolicy < ApplicationPolicy
  def all?
    raise Pundit::NotAuthorizedError, "You are not authorized to see all comments" unless @user&.admin?
    true
  end

  def show?
    raise Pundit::NotAuthorizedError, "You are not authorized to see this comment details" unless @user&.admin?
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
