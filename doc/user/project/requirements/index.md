---
type: reference, howto
stage: Plan
group: Certify
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Requirements Management **(ULTIMATE)**

> [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/2703) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 12.10.

With requirements, you can set criteria to check your products against. They can be based on users,
stakeholders, system, software, or anything else you find important to capture.

A requirement is an artifact in GitLab which describes the specific behavior of your product.
Requirements are long-lived and don't disappear unless manually cleared.

If an industry standard *requires* that your application has a certain feature or behavior, you can
[create a requirement](#create-a-requirement) to reflect this.
When a feature is no longer necessary, you can [archive the related requirement](#archive-a-requirement).

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
For an overview, see [GitLab 12.10 Introduces Requirements Management](https://www.youtube.com/watch?v=uSS7oUNSEoU).

![requirements list view](img/requirements_list_view_v12_10.png)

## Create a requirement

A paginated list of requirements is available in each project, and there you
can create a new requirement.

To create a requirement:

1. From your project page, go to **{requirements}** **Requirements**.
1. Click **New requirement**.
1. Enter a descriptive title and click **Create requirement**.

You will see the newly created requirement on the top of the list, as the requirements
list is sorted by creation date in descending order.

![requirement create view](img/requirement_create_view_v12_10.png)

## Edit a requirement

You can edit a requirement (if you have the necessary privileges) from the requirements
list page.

To edit a requirement:

1. From the requirements list, click **Edit** (**{pencil}**).
1. Update the title in text input field.
1. Click **Save changes**.

![requirement edit view](img/requirement_edit_view_v12_10.png)

## Archive a requirement

You can archive an open requirement (if you have the necessary privileges) while
you're in the **Open** tab.

From the requirements list page, click **Archive** (**{archive}**).

![requirement archive view](img/requirement_archive_view_v12_10.png)

As soon as a requirement is archived, it no longer appears in the **Open** tab.

## Reopen a requirement

You can view the list of archived requirements in the **Archived** tab.

![archived requirements list](img/requirements_archived_list_view_v12_10.png)

To reopen an archived requirement, click **Reopen**.

As soon as a requirement is reopened, it no longer appears in the **Archived** tab.

## Search for a requirement from the requirements list page

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/212543) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 13.1.

You can search for a requirement from the list of requirements using filtered search bar (similar to
that of Issues and Merge Requests) based on following parameters:

- Title
- Author username

To search, go to the list of requirements and click the field **Search or filter results**.
It will display a dropdown menu, from which you can add an author. You can also enter plain
text to search by epic title or description. When done, press <kbd>Enter</kbd> on your
keyboard to filter the list.

You can also sort requirements list by:

- Created date
- Last updated

## Allow requirements to be satisfied from a CI job

> - [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/2859) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 13.1.
> - [Added](https://gitlab.com/gitlab-org/gitlab/-/issues/215514) ability to specify individual requirements and their statuses in [GitLab Ultimate](https://about.gitlab.com/pricing/) 13.2.

GitLab supports [requirements test
reports](../../../ci/pipelines/job_artifacts.md#artifactsreportsrequirements-ultimate) now.
You can add a job to your CI pipeline that, when triggered, marks all existing
requirements as Satisfied.

### Add the manual job to CI

To configure your CI to mark requirements as Satisfied when the manual job is
triggered, add the code below to your `.gitlab-ci.yml` file.

```yaml
requirements_confirmation:
  when: manual
  allow_failure: false
  script:
    - mkdir tmp
    - echo "{\"*\":\"passed\"}" > tmp/requirements.json
  artifacts:
    reports:
      requirements: tmp/requirements.json
```

This definition adds a manually-triggered (`when: manual`) job to the CI
pipeline. It's blocking (`allow_failure: false`), but it's up to you what
conditions you use for triggering the CI job. Also, you can use any existing CI job
to mark all requirements as satisfied, as long as the `requirements.json`
artifact is generated and uploaded by the CI job.

When you manually trigger this job, the `requirements.json` file containing
`{"*":"passed"}` is uploaded as an artifact to the server. On the server side,
the requirement report is checked for the "all passed" record
(`{"*":"passed"}`), and on success, it marks all existing open requirements as
Satisfied.

#### Specifying individual requirements

It is possible to specify individual requirements and their statuses.

If the following requirements exist:

- `REQ-1` (with IID `1`)
- `REQ-2` (with IID `2`)
- `REQ-3` (with IID `3`)

It is possible to specify that the first requirement passed, and the second failed.
Valid values are "passed" and "failed".
By omitting a requirement IID (in this case `REQ-3`'s IID `3`), no result is noted.

```yaml
requirements_confirmation:
  when: manual
  allow_failure: false
  script:
    - mkdir tmp
    - echo "{\"1\":\"passed\", \"2\":\"failed\"}" > tmp/requirements.json
  artifacts:
    reports:
      requirements: tmp/requirements.json
```

### Add the manual job to CI conditionally

To configure your CI to include the manual job only when there are some open
requirements, add a rule which checks `CI_HAS_OPEN_REQUIREMENTS` CI variable.

```yaml
requirements_confirmation:
  rules:
  - if: "$CI_HAS_OPEN_REQUIREMENTS" == "true"
    when: manual
  - when: never
  allow_failure: false
  script:
    - mkdir tmp
    - echo "{\"*\":\"passed\"}" > tmp/requirements.json
  artifacts:
    reports:
      requirements: tmp/requirements.json
```
