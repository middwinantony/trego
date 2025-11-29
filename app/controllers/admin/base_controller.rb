module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin

    private

    def ensure_admin
      unless current_user.admin?
        redirect_to root_path, alert: "You are not authorized to access this area."
      end
    end
  end
end
