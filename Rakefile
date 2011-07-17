#-*- mode: ruby; -*-

require 'pathname'

DIR = Pathname.new('.').expand_path

def baseboxes
  @baseboxes ||= Dir[DIR + 'definitions/*'].inject({}) do |hash, dir|
    basebox = File.basename(dir)
    hash.merge(basebox.gsub(/\-chefbox/, '') => basebox)
  end
end

namespace :box do
  baseboxes.each do |shortname, flavor|
    desc "Build #{shortname}"
    task shortname do
      begin sh "rm -f #{flavor}.box" ; rescue ; end
      [ :build, :export, :destroy ].each do |command|
        sh "bundle exec vagrant basebox #{command} #{flavor}"
      end
      begin sh "bundle exec vagrant box remove #{flavor}" ; rescue ; end
      sh "bundle exec vagrant box add #{flavor} #{flavor}.box"
    end
  end

  desc "Build all"
  task :all => baseboxes.keys
end

desc "Download Cookbooks"
task :cookbooks do
  mkdir_p DIR + 'cookbooks'
  chdir('cookbooks') do
    sh "echo '*' >> .gitignore" unless File.exists?('.gitignore')
    %w[ apt chef ].each do |ckbk|
      unless File.directory?(ckbk)
        sh "git clone git@github.com:dysinger/cookbook-#{ckbk}.git #{ckbk}"
      end
    end
  end
end

