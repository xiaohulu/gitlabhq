class Spinach::Features::Groups < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths
  include SharedGroup
  include SharedUser

  step 'I should see back to dashboard button' do
    expect(page).to have_content 'Go to dashboard'
  end

  step 'I click link "Add members"' do
    find(:css, 'button.btn-new').click
  end

  step 'I should see group "Owned"' do
    expect(page).to have_content '@owned'
  end

  step 'I am a signed out user' do
    logout
  end

  step 'Group "Owned" has a public project "Public-project"' do
    group = owned_group

    @project = create :empty_project, :public,
                 group: group,
                 name: "Public-project"
  end

  step 'I should see project "Public-project"' do
    expect(page).to have_content 'Public-project'
  end

  step 'I should see group "Owned" projects list' do
    owned_group.projects.each do |project|
      expect(page).to have_link project.name
    end
  end

  step 'I should see projects activity feed' do
    expect(page).to have_content 'closed issue'
  end

  step 'I should see issues from group "Owned" assigned to me' do
    assigned_to_me(:issues).each do |issue|
      expect(page).to have_content issue.title
    end
  end

  step 'I should not see issues from the archived project' do
    @archived_project.issues.each do |issue|
      expect(page).not_to have_content issue.title
    end
  end

  step 'I should not see merge requests from the archived project' do
    @archived_project.merge_requests.each do |mr|
      expect(page).not_to have_content mr.title
    end
  end

  step 'I should see merge requests from group "Owned" assigned to me' do
    assigned_to_me(:merge_requests).each do |issue|
      expect(page).to have_content issue.title[0..80]
    end
  end

  step 'I change the role to "Developer"' do
    user = User.find_by(name: "Mary Jane")
    member = Group.find_by(name: "Owned").members.where(user_id: user.id).first

    page.within "#group_member_#{member.id}" do
      find(".js-toggle-button").click
      page.within "#edit_group_member_#{member.id}" do
        select 'Developer', from: 'group_member_access_level'
        click_on 'Save'
      end
    end

    page.within "#group_member_#{member.id}" do
      expect(page).to have_content "Developer"
    end
  end

  step 'I go to "Audit Events"' do
    find(:link, 'Audit Events').trigger('click')
  end

  step 'I should see the audit event listed' do
    page.within('table#audits') do
      expect(page).to have_content 'Add user access as reporter'
      expect(page).to have_content 'Change access level from reporter to developer'
      expect(page).to have_content 'Remove user access'
      expect(page).to have_content('John Doe', count: 3)
      expect(page).to have_content('Mary Jane', count: 3)
    end
  end

  step 'project from group "Owned" has issues assigned to me' do
    create :issue,
      project: project,
      assignee: current_user,
      author: current_user
  end

  step 'project from group "Owned" has merge requests assigned to me' do
    create :merge_request,
      source_project: project,
      target_project: project,
      assignee: current_user,
      author: current_user
  end

  Then 'I should be redirected to group page' do
    expect(current_path).to eq group_path(Group.last)
  end

  And 'I change group name' do
    page.within '#tab-edit' do
      fill_in 'group_name', with: 'new-name'
      click_button "Save group"
    end
  end

  step 'I change group "Owned" name to "new-name"' do
    fill_in 'group_name', with: 'new-name'
    fill_in 'group_path', with: 'new-name'
    click_button "Save group"
  end

  step 'I should see new group "Owned" name' do
    page.within ".navbar-gitlab" do
      expect(page).to have_content "new-name"
    end
  end

  step 'I change group "Owned" avatar' do
    attach_file(:group_avatar, File.join(Rails.root, 'spec', 'fixtures', 'banana_sample.gif'))
    click_button "Save group"
    owned_group.reload
  end

  step 'I should see new group "Owned" avatar' do
    expect(owned_group.avatar).to be_instance_of AvatarUploader
    expect(owned_group.avatar.url).to eq "/uploads/group/avatar/#{Group.find_by(name:"Owned").id}/banana_sample.gif"
  end

  step 'I should see the "Remove avatar" button' do
    expect(page).to have_link("Remove avatar")
  end

  step 'I have group "Owned" avatar' do
    attach_file(:group_avatar, File.join(Rails.root, 'spec', 'fixtures', 'banana_sample.gif'))
    click_button "Save group"
    owned_group.reload
  end

  step 'I remove group "Owned" avatar' do
    click_link "Remove avatar"
    owned_group.reload
  end

  step 'I should not see group "Owned" avatar' do
    expect(owned_group.avatar?).to eq false
  end

  step 'I should not see the "Remove avatar" button' do
    expect(page).not_to have_link("Remove avatar")
  end

  step 'Group "Owned" has archived project' do
    group = Group.find_by(name: 'Owned')
    @archived_project = create(:project, namespace: group, archived: true, path: "archived-project")
  end

  step 'I should see "archived" label' do
    expect(page).to have_xpath("//span[@class='label label-warning']", text: 'archived')
  end

  step 'LDAP enabled' do
    allow(Gitlab.config.ldap).to receive(:enabled).and_return(true)
  end

  step 'LDAP disabled' do
    allow(Gitlab.config.ldap).to receive(:enabled).and_return(false)
  end

  step 'I add a new LDAP synchronization' do
    page.within('form#new_ldap_group_link') do
      find('#ldap_group_link_cn', visible: false).set('my-group-cn')
      # fill_in('LDAP Group cn', with: 'my-group-cn', visible: false)
      select 'Developer', from: "ldap_group_link_group_access"
      click_button 'Add synchronization'
    end
  end

  step 'I see a new LDAP synchronization listed' do
    expect(page).not_to have_content('No synchronizations yet')
    expect(page).to have_content('As Developer on ldap server')
  end

  step 'I visit group "NonExistentGroup" page' do
    visit group_path(-1)
  end

  step 'the archived project have some issues' do
    create :issue,
      project: @archived_project,
      assignee: current_user,
      author: current_user
  end

  step 'the archived project have some merge requests' do
    create :merge_request,
      source_project: @archived_project,
      target_project: @archived_project,
      assignee: current_user,
      author: current_user
  end

  private

  def assigned_to_me(key)
    project.send(key).where(assignee_id: current_user.id)
  end

  def project
    owned_group.projects.first
  end
end
