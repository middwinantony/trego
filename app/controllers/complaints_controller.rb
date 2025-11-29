class ComplaintsController < ApplicationController
  before_action :authenticate_user!

  def index
    @complaints = current_user.complaints.order(created_at: :desc)
  end

  def new
    @complaint = Complaint.new
  end

  def create
    @complaint = current_user.complaints.build(complaint_params)

    if @complaint.save
      redirect_to complaints_path, notice: "Complaint submitted successfully. We'll review it shortly."
    else
      render :new
    end
  end

  def show
    @complaint = current_user.complaints.find(params[:id])
  end

  private

  def complaint_params
    params.require(:complaint).permit(:subject, :description, :ride_id)
  end
end
