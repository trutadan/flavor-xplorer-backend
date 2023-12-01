class UserAccountPolicy < ApplicationPolicy
  attr_reader :user, :user_account

  def initialize(user, user_account)
    @user = user
    @user_account = user_account
  end

  def index?
    raise Pundit::NotAuthorizedError, "You are not authorized to view all user accounts" unless @user&.admin?
    true
  end

  def show?
    raise Pundit::NotAuthorizedError, "You are not authorized to view this user" unless @user == @user_account&.user || @user&.admin?
    true
  end

  def update?
    raise Pundit::NotAuthorizedError, "You are not authorized to update this user" unless @user == @user_account&.user || @user&.admin?
    true
  end
end
