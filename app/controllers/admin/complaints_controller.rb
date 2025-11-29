module Admin
  class ComplaintsController < BaseController
    def index
      @complaints = Complaint.includes(:user, :ride).order(created_at: :desc)

      if params[:status].present?
        @complaints = @complaints.where(status: params[:status])
      end

      @complaints = @complaints.page(params[:page]).per(20) if defined?(Kaminari)
    end

    def show
      @complaint = Complaint.find(params[:id])
    end

    def update
      @complaint = Complaint.find(params[:id])

      if @complaint.update(complaint_params)
        redirect_to admin_complaints_path, notice: "Complaint status updated."
      else
        render :show
      end
    end

    private

    def complaint_params
      params.require(:complaint).permit(:status)
    end
  end
end
