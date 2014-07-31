class ProjectsController < ApplicationController

	def index
		@user = current_client || current_developer

		if params[:status]
			@projects = @user.projects.where(status: params[:status])
		else
			@projects = @user.projects
		end

	
	# @client.projects.each do |project|
		# 	@project_pending if project.status == 'Pending'
		# 	@project_in_progress if project.status == 'In Progress'
		# 	@project_completed if project.status == 'Completed'
		# 	@project_declined if project.status == 'Declined'
		# end

	end

	def new
		@client = Client.find params[:client_id]
		@project = @client.projects.new
	end

	def create
		@client = Client.find params[:client_id]
		skill = params['project'].delete('skills')
		language = params['project'].delete('languages')
		params['project']['status'] = 'Pending'
		@project = @client.projects.create project_params

		added_skills = skill.split(',').map(&:strip).uniq.map do |skill_name|
			Skill.find_or_create_by(name: skill_name)
		end
		added_languages = language.split(',').map(&:strip).uniq.map do |language_name|
			Language.find_or_create_by(name: language_name)
		end
		@project.languages << added_languages
		@project.skills << added_skills
		redirect_to client_project_path(@client, @project)
	end

	def show
		if current_client 
			@client = Client.find params[:client_id]
			@project = @client.projects.find params[:id]
		elsif current_developer
			@developer = Developer.find params[:developer_id]
			@project = @developer.projects.find params[:id]
		end	
	end

	def edit
 		@client = Client.find params[:client_id] 
 		@project = @client.projects.find params[:id]
	end

	def update
		@project = Project.find(params[:id])
		@status = @project.statuses.find_by(developer: current_developer)

		@status.status = params[:answer]
		@status.save
		if @status.status == 'declined'
			redirect_to developer_projects_path(current_developer)
		else 
			# redirect_to new_developer_quote_path(current_developer)
			# redirect_to '/*'
			redirect_to developer_projects_path(current_developer)
		end
	end

	private
	def project_params
		params[:project].permit(:name, :deadline, :client_id, :budget, :projectIndustry, :skills, :description, :status)
	end
end
