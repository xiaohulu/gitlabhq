require 'spec_helper'

describe 'Import multiple repositories by uploading a manifest file', :js, :postgresql do
  include Select2Helper

  let(:user) { create(:admin) }
  let(:group) { create(:group) }

  before do
    sign_in(user)

    group.add_owner(user)
  end

  it 'parses manifest file and list repositories' do
    visit new_import_manifest_path

    attach_file('manifest', Rails.root.join('spec/fixtures/aosp_manifest.xml'))
    click_on 'List available repositories'

    expect(page).to have_button('Import all repositories')
    expect(page).to have_content('https://android-review.googlesource.com/platform/build/blueprint')
  end

  it 'imports succesfully imports a project' do
    visit new_import_manifest_path

    attach_file('manifest', Rails.root.join('spec/fixtures/aosp_manifest.xml'))
    click_on 'List available repositories'

    page.within(first_row) do
      click_on 'Import'

      expect(page).to have_content 'Done'
      expect(page).to have_content("#{group.full_path}/build/make")
    end
  end

  def first_row
    page.all('table.import-jobs tbody tr')[0]
  end
end
