# frozen_string_literal: true

require 'fast_spec_helper'
require 'rspec-parameterized'
require_relative 'danger_spec_helper'

require 'gitlab/danger/sidekiq_queues'

RSpec.describe Gitlab::Danger::SidekiqQueues do
  using RSpec::Parameterized::TableSyntax
  include DangerSpecHelper

  let(:fake_git) { double('fake-git') }
  let(:fake_danger) { new_fake_danger.include(described_class) }

  subject(:sidekiq_queues) { fake_danger.new(git: fake_git) }

  describe '#changed_queue_files' do
    where(:modified_files, :changed_queue_files) do
      %w(app/workers/all_queues.yml ee/app/workers/all_queues.yml foo) | %w(app/workers/all_queues.yml ee/app/workers/all_queues.yml)
      %w(app/workers/all_queues.yml ee/app/workers/all_queues.yml) | %w(app/workers/all_queues.yml ee/app/workers/all_queues.yml)
      %w(app/workers/all_queues.yml foo) | %w(app/workers/all_queues.yml)
      %w(ee/app/workers/all_queues.yml foo) | %w(ee/app/workers/all_queues.yml)
      %w(foo) | %w()
      %w() | %w()
    end

    with_them do
      it do
        allow(fake_git).to receive(:modified_files).and_return(modified_files)

        expect(sidekiq_queues.changed_queue_files).to match_array(changed_queue_files)
      end
    end
  end

  describe '#added_queue_names' do
    it 'returns queue names added by this change' do
      old_queues = { post_receive: nil }

      allow(sidekiq_queues).to receive(:old_queues).and_return(old_queues)
      allow(sidekiq_queues).to receive(:new_queues).and_return(old_queues.merge(merge: nil, process_commit: nil))

      expect(sidekiq_queues.added_queue_names).to contain_exactly(:merge, :process_commit)
    end
  end

  describe '#changed_queue_names' do
    it 'returns names for queues whose attributes were changed' do
      old_queues = {
        merge: { name: :merge, urgency: :low },
        post_receive: { name: :post_receive, urgency: :high },
        process_commit: { name: :process_commit, urgency: :high }
      }

      new_queues = old_queues.merge(mailers: { name: :mailers, urgency: :high },
                                    post_receive: { name: :post_receive, urgency: :low },
                                    process_commit: { name: :process_commit, urgency: :low })

      allow(sidekiq_queues).to receive(:old_queues).and_return(old_queues)
      allow(sidekiq_queues).to receive(:new_queues).and_return(new_queues)

      expect(sidekiq_queues.changed_queue_names).to contain_exactly(:post_receive, :process_commit)
    end
  end
end
