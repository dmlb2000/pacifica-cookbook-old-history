#
# Cookbook Name:: pacifica
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'test::pacifica' do
  context 'stepping into archive interface' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        step_into: 'pacifica_archiveinterface'
      )
      runner.converge(described_recipe)
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
  end
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
