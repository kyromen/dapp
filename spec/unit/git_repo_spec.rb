require_relative '../spec_helper'

describe Dapp::Dimg::GitRepo do
  include SpecHelper::Common
  include SpecHelper::Dimg
  include SpecHelper::Git

  def git_init(git_dir: '.')
    super
    expect(File.exist?(File.join(git_dir, '.git'))).to be_truthy
  end

  def git_change_and_commit(*args, git_dir: '.', **kwargs)
    @commit_counter ||= 0
    super
    @commit_counter += 1

    expect(git_log(git_dir: git_dir).count).to eq @commit_counter
  end

  def dapp_remote_init
    git_init(git_dir: 'remote')

    @remote = Dapp::Dimg::GitRepo::Remote.new(dapp, 'local_remote', url: 'remote/.git')

    expect(File.exist?(@remote.path)).to be_truthy
    expect(@remote.path.to_s[/.*\/([^\/]*\/[^\/]*\/[^\/]*)/, 1]).to eq "remote_git_repo/#{Dapp::Dimg::GitRepo::Remote::CACHE_VERSION}/#{dapp.consistent_uniq_slugify("local_remote")}"
  end

  it 'Remote#init', test_construct: true do
    dapp_remote_init
  end

  it 'Remote#fetch', test_construct: true do
    dapp_remote_init
    git_change_and_commit(git_dir: 'remote')
    @remote.fetch!
    expect(@remote.latest_commit('master')).to eq git_latest_commit(git_dir: 'remote')
  end

  it 'Own', test_construct: true do
    git_init

    own = Dapp::Dimg::GitRepo::Own.new(dapp)
    expect(own.latest_commit).to eq git_latest_commit

    git_change_and_commit
    expect(own.latest_commit).to eq git_latest_commit
  end

  context 'submodule_url' do
    def repo_submodule_url(submodule_url, remote_origin_url = nil, remote_origin_url_protocol = nil)
      dapp_remote_init
      double_remote_repo = @remote
      allow(double_remote_repo).to receive(:remote_origin_url) { remote_origin_url }
      allow(double_remote_repo).to receive(:remote_origin_url_protocol) { remote_origin_url_protocol }
      double_remote_repo.send(:submodule_url, submodule_url)
    end

    ['git@github.com:group/submodule.git', 'https://github.com/group/submodule.git', '/local/submodule/path'].each do |submodule_url|
      it submodule_url, test_construct: true do
        expect(repo_submodule_url(submodule_url)).to eq submodule_url
      end
    end

    context 'relative_url' do
      [
        ['git@github.com:group/project.git', :ssh, 'git@github.com:group/submodule.git'],
        ['https://github.com/group/project.git', :https, 'https://github.com/group/submodule.git'],
      ].each do |remote_origin_url, remote_origin_url_protocol, expectation|
        it remote_origin_url_protocol, test_construct: true do
          expect(repo_submodule_url('../submodule.git', remote_origin_url, remote_origin_url_protocol)).to eq expectation
        end
      end

      it 'local', test_construct: true do
        expect { repo_submodule_url('../submodule.git', '/local/path', :noname) }.to raise_error RuntimeError
      end
    end
  end
end
