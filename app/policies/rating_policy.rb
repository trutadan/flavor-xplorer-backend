class RatingPolicy < ApplicationPolicy
  def index?
    raise Pundit::NotAuthorizedError, "You are not authorized to update this post ratings" unless @user&.admin?
    true
  end

  def all?
    raise Pundit::NotAuthorizedError, "You are not authorized to see all post ratings" unless @user&.admin?
    true
  end
end
