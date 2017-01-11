#
# Cookbook Name:: pacifica
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'test::pacifica' do
  context 'stepping into archive interface' do
    let(:chef_run) do
      Chef::Config[:config_file] = '/etc/chef/default.rb'
      ChefSpec::ServerRunner.new(
        platform: 'centos', version: '7.2.1511',
        step_into: 'pacifica_archiveinterface'
      ).converge(described_recipe)
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
      expect(chef_run).to run_python_execute('archiveinterface_requirements')
    end
    it 'builds python code' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/opt/archiveinterface/source/setup.py').and_return(true)
      expect(chef_run).to run_python_execute('archiveinterface_build')
    end
    it 'creates systemd service' do
      expect(chef_run).to create_systemd_service('archiveinterface')
    end
  end
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos', version: '7.2.1511'
      )
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
