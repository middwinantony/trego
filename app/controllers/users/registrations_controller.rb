class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :set_role, only: [:new, :create]

  def new
    build_resource({})
    resource.role = @role
    respond_with resource
  end

  def create
    build_resource(sign_up_params)
    resource.role = @role if resource.role.blank?

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def set_role
    @role = params[:role] || params.dig(:user, :role) || 'customer'
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone, :role])
  end

  def after_sign_up_path_for(resource)
    if resource.driver?
      new_subscription_path
    else
      dashboard_path
    end
  end
end
