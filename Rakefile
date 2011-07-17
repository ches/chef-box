#-*- mode: ruby; -*-

require 'pathname'

DIR = Pathname.new('.').expand_path

# Could go away if Veewee had an unformatted version of
# Veewee::Session.list_definitions that we could call...
def baseboxes
  @baseboxes ||= Dir[DIR + 'definitions/*'].map { |dir| File.basename(dir) }
end

namespace :box do
  baseboxes.each do |flavor|
    desc "Build #{flavor}"
    task flavor do
      begin sh "rm -f #{flavor}.box" ; rescue ; end
      [ :build, :export, :destroy ].each do |command|
        sh "bundle exec vagrant basebox #{command} #{flavor}"
      end
      begin sh "bundle exec vagrant box remove #{flavor}" ; rescue ; end
      sh "bundle exec vagrant box add #{flavor} #{flavor}.box"
    end
  end

  desc "Build all"
  task :all => baseboxes
end

desc "Download Cookbooks"
task :cookbooks do
  `mkdir -p #{DIR}/cookbooks`
  `echo '*' >> #{DIR}/cookbooks/.gitignore`
  `[ ! -d cookbooks/apt ] && \
git clone git@github.com:dysinger/cookbook-apt.git \
#{DIR}/cookbooks/apt`
  `[ ! -d cookbooks/chef ] && \
git clone git@github.com:dysinger/cookbook-chef.git \
#{DIR}/cookbooks/chef`
end

