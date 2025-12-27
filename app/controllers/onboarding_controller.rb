class OnboardingController < ApplicationController
  def welcome
    # Display welcome screen with role selection
  end

  def phone
    session[:onboarding_role] = params[:role] if params[:role].present?
    # Display phone number entry screen
  end

  def send_code
    phone = "#{params[:country_code]}#{params[:phone]}"
    session[:onboarding_phone] = phone
    session[:onboarding_role] = params[:role]

    # Generate 6-digit verification code
    code = rand(100000..999999).to_s
    session[:verification_code] = code
    session[:code_expires_at] = 5.minutes.from_now

    # TODO: Send SMS using Twilio or similar service
    # For now, we'll just log it
    Rails.logger.info "Verification code for #{phone}: #{code}"

    # In development, you can display it in flash
    if Rails.env.development?
      flash[:notice] = "Verification code: #{code} (Development mode)"
    end

    redirect_to onboarding_verify_code_path
  end

  def verify_code
    # Display verification code entry screen
  end

  def check_code
    submitted_code = params[:verification_code]
    stored_code = session[:verification_code]
    expires_at = session[:code_expires_at]&.to_time

    if stored_code.nil? || expires_at.nil? || Time.current > expires_at
      flash[:alert] = "Verification code expired. Please request a new one."
      redirect_to onboarding_phone_path(role: session[:onboarding_role])
      return
    end

    if submitted_code == stored_code
      session[:phone_verified] = true
      session.delete(:verification_code)
      session.delete(:code_expires_at)
      redirect_to onboarding_profile_path
    else
      flash[:alert] = "Invalid verification code. Please try again."
      redirect_to onboarding_verify_code_path
    end
  end

  def resend_code
    if session[:onboarding_phone].present?
      # Generate new code
      code = rand(100000..999999).to_s
      session[:verification_code] = code
      session[:code_expires_at] = 5.minutes.from_now

      Rails.logger.info "Resent verification code for #{session[:onboarding_phone]}: #{code}"

      if Rails.env.development?
        flash[:notice] = "Verification code resent: #{code} (Development mode)"
      else
        flash[:notice] = "Verification code resent to your phone"
      end
    else
      flash[:alert] = "No phone number found. Please start over."
    end

    redirect_to onboarding_verify_code_path
  end

  def profile
    unless session[:phone_verified]
      redirect_to onboarding_phone_path(role: session[:onboarding_role])
      return
    end
    # Display profile setup screen
  end

  def create_profile
    unless session[:phone_verified]
      redirect_to onboarding_phone_path(role: session[:onboarding_role])
      return
    end

    # Generate random password for user
    password = SecureRandom.hex(16)

    user = User.new(
      name: params[:name],
      email: params[:email],
      phone: session[:onboarding_phone],
      role: session[:onboarding_role] || 'customer',
      password: password,
      password_confirmation: password
    )

    if params[:profile_photo].present?
      user.profile_photo.attach(params[:profile_photo])
    end

    if user.save
      sign_in(user)
      session[:user_just_created] = true
      redirect_to onboarding_permissions_path
    else
      flash[:alert] = user.errors.full_messages.join(", ")
      redirect_to onboarding_profile_path
    end
  end

  def permissions
    unless user_signed_in?
      redirect_to onboarding_welcome_path
      return
    end
    # Display permissions request screen
  end

  def save_permissions
    unless user_signed_in?
      redirect_to onboarding_welcome_path
      return
    end

    # Store permission preferences (you can add these fields to User model if needed)
    # For now, we'll just proceed to the next step

    if current_user.driver?
      redirect_to onboarding_documents_path
    else
      redirect_to dashboard_path
    end
  end

  def documents
    unless user_signed_in? && current_user.driver?
      redirect_to dashboard_path
      return
    end
    # Display document upload screen for drivers
  end

  def complete
    unless user_signed_in?
      redirect_to onboarding_welcome_path
      return
    end

    # Clear onboarding session data
    session.delete(:onboarding_phone)
    session.delete(:onboarding_role)
    session.delete(:phone_verified)
    session.delete(:verification_code)
    session.delete(:code_expires_at)

    redirect_to dashboard_path
  end
end
