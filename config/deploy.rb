require 'vendor/plugins/thinking-sphinx/recipes/thinking_sphinx'

set :application, "sentience_trader"
set :repository,  "svn+ssh://robert@app1.streamburst.net/srv/svn/repositories/svnrep/SentienceTrader"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "st.decyphermedia.com"
role :web, "st.decyphermedia.com"
role :db,  "st.decyphermedia.com", :primary => true

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

task :before_update_code, :roles => [:app] do
  thinking_sphinx.stop
end

task :after_update_code, :roles => [:app] do
  symlink_sphinx_indexes
  thinking_sphinx.configure
  thinking_sphinx.start
end

task :symlink_sphinx_indexes, :roles => [:app] do
  run "ln -nfs #{shared_path}/db/sphinx #{current_path}/db/sphinx"
end

end

deploy.task :start do
# nothing
end
