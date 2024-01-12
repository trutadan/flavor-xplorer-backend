class UserPolicy < ApplicationPolicy
    def index?
        raise Pundit::NotAuthorizedError, "You are not authorized to view all users" unless user&.admin?
        true
    end

    def show?
        raise Pundit::NotAuthorizedError, "You are not authorized to view this user" unless user&.admin? || current_user?(user)
        true
    end

    def update?
        raise Pundit::NotAuthorizedError, "You are not authorized to update this user" unless user&.admin? || current_user?(user)
        true
    end

    def destroy?
        raise Pundit::NotAuthorizedError, "You are not authorized to delete this user" unless user&.admin?
        true
    end

    # def followers?
    #     raise Pundit::NotAuthorizedError, "You are not authorized to view the followers of this user" unless user == record || user.admin?
    #     true
    # end
    
    # def following?
    #     raise Pundit::NotAuthorizedError, "You are not authorized to view the users followed by this user" unless user == record || user.admin?
    #     true
    # end      
end
