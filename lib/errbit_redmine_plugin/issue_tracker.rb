require 'redmine_client'

module ErrbitRedminePlugin
  class IssueTracker < ErrbitPlugin::IssueTracker

    LABEL = "redmine"

    FIELDS = [
      [:account, {
        :label       => "Redmine URL",
        :placeholder => "http://www.redmine.org/"
      }],
      [:api_token, {
        :placeholder => "API Token for your account"
      }],
      [:username, {
        :placeholder => "Your username"
      }],
      [:password, {
        :placeholder => "Your password"
      }],
      [:project_id, {
        :label       => "Ticket Project",
        :placeholder => "Redmine Project where tickets will be created"
      }],
      [:alt_project_id, {
        :optional    => true,
        :label       => "App Project",
        :placeholder => "Where app's files & revisions can be viewed. (Leave blank to use the above project by default)"
      }],
      [:tracker_id, {
        :optional    => true,
        :label       => "Issue Tracker Id",
        :placeholder => "The tracker where tickets will be created. (Leave blank to use default)"
      }]
    ]

    NOTE = "REST web service must be enabled in Redmine"

    def self.label
      LABEL
    end

    def self.note
      NOTE
    end

    def self.fields
      FIELDS
    end

    def self.icons
      @icons ||= {
        create: [
          'image/png', ErrbitRedminePlugin.read_static_file('redmine_create.png')
        ],
        goto: [
          'image/png', ErrbitRedminePlugin.read_static_file('redmine_goto.png'),
        ],
        inactive: [
          'image/png', ErrbitRedminePlugin.read_static_file('redmine_inactive.png'),
        ]
      }
    end

    def url
      account = params['account']
      project_id = params['project_id']

      acc_url = account.start_with?('http') ? account : "http://#{account}"
      acc_url = acc_url.gsub(/\/$/, '')
      URI.parse("#{acc_url}/projects/#{project_id}").to_s
    rescue URI::InvalidURIError
    end

    def comments_allowed?
      false
    end

    # configured properly if all the fields are filled in
    def configured?
      non_empty_params = params.reject { |k,v| v.empty? }.keys.map(&:intern)
      (required_fields - non_empty_params).empty?
    end

    def required_fields
      FIELDS.reject { |k,v| v[:optional] }.map { |f| f[0] }.map(&:intern)
    end

    def errors
      errors = []
      unless configured?
        errors << [:base, 'You must specify your Redmine URL, API token, Username, Password and Project ID']
      end
      errors
    end

    def create_issue(problem, reported_by = nil)
      token  = params['api_token']
      acc    = params['account']
      user   = params['username']
      passwd = params['password']
      project_id = params['project_id']
      tracker_id = params['tracker_id']

      RedmineClient::Base.configure do
        self.token = token
        self.user = user
        self.password = passwd
        self.site = acc
        self.format = :xml
      end

      issue = RedmineClient::Issue.new(:project_id => project_id)
      issue.subject = "[#{ problem.environment }][#{ problem.where }] #{problem.message.to_s.truncate(100)}"
      issue.description = self.class.body_template.result(binding)
      issue.tracker_id = tracker_id if tracker_id.present?
      issue.save!

      problem.update_attributes(
        :issue_link => issue_link(issue),
        :issue_type => LABEL
      )
    end

    def issue_link(issue)
      project_id = params['project_id']

      RedmineClient::Issue.site.to_s
        .sub(/#{RedmineClient::Issue.site.path}$/, '') <<
      RedmineClient::Issue.element_path(issue.id, :project_id => project_id)
        .sub(/\.xml\?project_id=#{project_id}$/, "\?project_id=#{project_id}")
    end
  end
end
