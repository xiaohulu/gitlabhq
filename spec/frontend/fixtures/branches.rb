# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::BranchesController, '(JavaScript fixtures)', type: :controller do
  include JavaScriptFixturesHelpers

  let(:admin) { create(:admin) }
  let(:namespace) { create(:namespace, name: 'frontend-fixtures' )}
  let(:project) { create(:project, :repository, namespace: namespace, path: 'branches-project') }

  render_views

  before(:all) do
    clean_frontend_fixtures('branches/')
  end

  before do
    sign_in(admin)
  end

  after do
    remove_repository(project)
  end

  it 'branches/new_branch.html' do
    get :new, params: {
      namespace_id: project.namespace.to_param,
      project_id: project
    }

    expect(response).to be_successful
  end
end
