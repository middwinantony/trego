module Admin
  class KycDocumentsController < BaseController
    def index
      @kyc_documents = KycDocument.includes(:user).order(created_at: :desc)

      if params[:status].present?
        @kyc_documents = @kyc_documents.where(status: params[:status])
      end
    end

    def show
      @kyc_document = KycDocument.find(params[:id])
    end

    def approve
      @kyc_document = KycDocument.find(params[:id])
      @kyc_document.update(status: 'approved')

      # Update user KYC status if all documents are approved
      update_user_kyc_status(@kyc_document.user)

      redirect_to admin_kyc_documents_path, notice: "Document approved."
    end

    def reject
      @kyc_document = KycDocument.find(params[:id])
      @kyc_document.update(status: 'rejected')

      # Update user KYC status
      @kyc_document.user.update(kyc_status: 'rejected')

      redirect_to admin_kyc_documents_path, alert: "Document rejected."
    end

    private

    def update_user_kyc_status(user)
      all_approved = user.kyc_documents.where(document_type: %w[drivers_license vehicle_registration vehicle_insurance]).all? { |doc| doc.status == 'approved' }

      if all_approved
        user.update(kyc_status: 'approved')
      end
    end
  end
end
