class BookmarkPolicy < ApplicationPolicy
  def all?
    raise Pundit::NotAuthorizedError, "You are not authorized to see all bookmarks" unless @user&.admin?
    true
  end
end
