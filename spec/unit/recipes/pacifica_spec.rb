#
# Cookbook Name:: pacifica
# Spec:: pacifica
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'test::pacifica' do
  custom_resource = {
    pacifica_archiveinterface: 'archiveinterface',
    pacifica_cartfrontend: 'cartwsgi',
    pacifica_cartbackend: 'cartd',
    pacifica_metadata: 'metadata',
    pacifica_policy: 'policy',
    pacifica_uniqueid: 'uniqueid',
    pacifica_ingestbackend: 'ingestd',
    pacifica_ingestfrontend: 'ingestwsgi',
    pacifica_status: 'status',
    pacifica_reporting: 'reporting',
    pacifica_nginx: 'nginxai',
    pacifica_varnish: 'varnishai',
  }

  before do
    allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
    stub_command(%r{/ls \/.*\/config.php/}).and_return(false)
    stub_command('grep -q http://127.0.0.1 /opt/status/source/application/config/production/config.php').and_return(true)
    stub_command('grep -q http://127.0.0.1 /opt/reporting/source/application/config/production/config.php').and_return(true)
    stub_command('/usr/sbin/apache2 -t').and_return(true)
    stub_command('/usr/sbin/httpd -t').and_return(true)
  end
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on an #{platform.capitalize}-#{version} box" do
        let(:chef_run) do
          runner = ChefSpec::ServerRunner.new(
            platform: platform, version: version, step_into: custom_resource.keys
          )
          runner.converge(described_recipe)
        end

        custom_resource.each do |resource_key, resource_value|
          it "#{resource_key} converges successfully" do
            expect { chef_run }.to_not raise_error
          end

          it "installs git client for #{resource_key}" do
            expect(chef_run).to install_git_client(resource_value)
          end

          it "creates directory for #{resource_key}" do
            expect(chef_run).to create_directory("/opt/#{resource_value}")
          end

          it "syncs git repository for #{resource_key}" do
            expect(chef_run).to sync_git("/opt/#{resource_value}/source")
          end

          it "installs python runtime for #{resource_key}" do
            expect(chef_run).to install_python_runtime(resource_value)
          end

          it "creates python virtual environment for #{resource_key}" do
            expect(chef_run).to create_python_virtualenv(
              "/opt/#{resource_value}/virtualenv"
            )
          end

          it "installs python requirements for #{resource_key}" do
            expect(chef_run).to run_python_execute(
              "#{resource_value}_requirements"
            )
          end

          it "builds python code for #{resource_key}" do
            allow(File).to receive(:exist?).and_call_original
            allow(File).to receive(:exist?).with(
              "/opt/#{resource_value}/source/setup.py"
            ).and_return(true)
            expect(chef_run).to run_python_execute("#{resource_value}_build")
          end

          it "creates systemd service for #{resource_key}" do
            expect(chef_run).to create_systemd_service(resource_value)
          end
        end
      end
    end
  end
end
