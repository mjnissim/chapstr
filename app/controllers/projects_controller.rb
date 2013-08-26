class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy,
    :extension_setup, :set_refresh]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.masters.sort_by{ |p| p.initialized? ? 1 : 0 }
    @project = Project.new
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        # format.html { redirect_to projects_path, notice: 'Project was successfully created.' }
        format.html { redirect_to projects_path }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end
  
  def extension_setup
    @extension = params[:extension]
    respond_to do |format|
      format.js do
        if @extension.blank?
          render nothing: true
        else
          @project.tt_module = @extension.camelize
          render partial: "extensions/#{@extension}/setup"
        end
      end
    end
  end
  
  def set_refresh
    refresh = session[@project.id][:set_refresh]
    session[@project.id][:set_refresh] = !!!refresh
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
      session[@project.id]={} unless session[@project.id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:title, :start, :finish, :quote, :per_hour, :expected_percentage, :hours_so_far, :hours_expected, :milestone, :milestone_label, :date_started, :date_ended, :completed, :after_finalised, :finalised, :project_id, :tt_module, :tt_project_id, :comments)
    end
end
