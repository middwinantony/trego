class KycDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_driver

  def index
    @kyc_documents = current_user.kyc_documents.order(created_at: :desc)
  end

  def new
    @kyc_document = KycDocument.new
  end

  def create
    @kyc_document = current_user.kyc_documents.build(kyc_document_params)

    if @kyc_document.save
      # Update user KYC status if all required documents are uploaded
      update_user_kyc_status
      redirect_to kyc_documents_path, notice: "Document uploaded successfully. It will be reviewed shortly."
    else
      render :new
    end
  end

  def show
    @kyc_document = current_user.kyc_documents.find(params[:id])
  end

  private

  def kyc_document_params
    params.require(:kyc_document).permit(:document_type, :file)
  end

  def ensure_driver
    unless current_user.driver?
      redirect_to root_path, alert: "Only drivers can upload KYC documents"
    end
  end

  def update_user_kyc_status
    required_documents = %w[drivers_license vehicle_registration vehicle_insurance]
    uploaded_types = current_user.kyc_documents.pluck(:document_type)

    if (required_documents - uploaded_types).empty?
      current_user.update(kyc_status: 'submitted')
    end
  end
end
