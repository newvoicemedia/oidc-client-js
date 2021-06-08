# This tasks runs target specific build prereqs checks/validation.
namespace :ci do
  desc 'NPM buid prereqs'
  task :npm_build_prereqs do
    # If VOLTA_NPM_TOKEN is not set, check if any docker-compose files require it
    trap_unset_environment_variable('VOLTA_NPM_TOKEN')
  end
end
