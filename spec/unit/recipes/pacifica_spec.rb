#
# Cookbook Name:: pacifica
# Spec:: pacifica
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'test::pacifica' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
    stub_command(/ls \/.*\/config.php/).and_return(false)
    stub_command("grep -q http://127.0.0.1 /opt/status/source/application/config/production/config.php").and_return(true)
    stub_command("grep -q http://127.0.0.1 /opt/reporting/source/application/config/production/config.php").and_return(true)
  end
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on an #{platform.capitalize}-#{version} box" do
        let(:chef_run) do
          runner = ChefSpec::ServerRunner.new(
            platform: platform, version: version, step_into: %w(
              pacifica_archiveinterface
              pacifica_cartbackend
              pacifica_cartfrontend
              pacifica_archiveinterface
              pacifica_ingestfrontend
              pacifica_metadata
              pacifica_nginx
              pacifica_policy
              pacifica_reporting
              pacifica_status
              pacifica_uniqueid
              pacifica_varnish
            )
          )
          runner.converge(described_recipe)
        end

        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end

        it 'installs git client' do
          expect(chef_run).to install_git_client('archiveinterface')
        end

        it 'creates directory' do
          expect(chef_run).to create_directory('/opt/archiveinterface')
        end

        it 'syncs git repository' do
          expect(chef_run).to sync_git('/opt/archiveinterface/source')
        end

        it 'installs python runtime' do
          expect(chef_run).to install_python_runtime('archiveinterface')
        end

        it 'creates python virtual environment' do
          expect(chef_run).to create_python_virtualenv(
            '/opt/archiveinterface/virtualenv'
          )
        end

        it 'installs python requirements' do
          expect(chef_run).to run_python_execute(
            'archiveinterface_requirements'
          )
        end

        it 'builds python code' do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(
            '/opt/archiveinterface/source/setup.py'
          ).and_return(true)
          expect(chef_run).to run_python_execute('archiveinterface_build')
        end

        it 'creates systemd service' do
          expect(chef_run).to create_systemd_service('archiveinterface')
        end
      end
    end
  end
end
