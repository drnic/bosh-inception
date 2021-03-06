module Inception
  # Perform converge chef cookbooks upon inception server
  class InceptionServerCookbook
    include FileUtils

    attr_reader :server, :settings, :project_dir

    class InvalidTarget < StandardError; end

    def initialize(inception_server, settings, project_dir)
      @server = inception_server
      @settings = settings
      @project_dir = project_dir
    end

    def prepare
      FileUtils.chdir(project_dir) do
        prepare_project_dir
        knife_solo :prepare unless ignore_chef_preparations?
      end
    end

    # To be invoked within the settings_dir
    def converge
      FileUtils.chdir(project_dir) do
        knife_solo :cook
      end
    end

    def ignore_chef_preparations?
      @settings.exists?("cookbook.prepared")
    end

    def user_host; server.user_host; end
    def key_path; server.private_key_path; end

    def knife_solo(command)
      attributes = cookbook_attributes_for_inception.to_json
      sh %Q{knife solo #{command} #{user_host} -i #{key_path} -j '#{attributes}' -r 'bosh_inception'}
    end

    protected
    def prepare_project_dir
      prepare_cookbook
      prepare_knife_config
      prepare_berksfile
    end

    def prepare_cookbook
      mkdir_p("cookbooks")
      rm_rf("cookbooks/bosh_inception")
      cp_r(inception_cookbook_path, "cookbooks/")
    end

    def prepare_knife_config
      mkdir_p("nodes") # needed for knife solo
    end

    def prepare_berksfile
      unless File.exists?("Berksfile")
        cp_r(File.join(gem_root_path, "Berksfile"), "Berksfile")
      end
    end

    def cookbook_attributes_for_inception
      {
        "disk" => {
          "mounted" => true,
          "device" => settings.inception.provisioned.disk_device.internal
        },
        "git" => {
          "name" => settings.git.name,
          "email" => settings.git.email
        },
        "user" => {
          "username" => settings.inception.provisioned.username
        },
        "fog" => settings.provider.credentials
      }
    end

    def gem_root_path
      File.expand_path("../../..", __FILE__)
    end

    def inception_cookbook_path
      File.join(gem_root_path, "cookbooks/bosh_inception")
    end
  end
end