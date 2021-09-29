class ApplicationController < ActionController::Base
  include LocalesHelper
  include ProtectedFromForgery
  include ErrorRescueHelper
  include CurrentUserHelper
  include SentryHelper
  include PrettyUrlHelper
  include LoadAndAuthorize
  include EmailHelper
  include ApplicationHelper
  helper :email
  helper :formatted_date

  around_action :process_time_zone          # LocalesHelper
  around_action :use_preferred_locale       # LocalesHelper
  before_action :deny_spam_users            # CurrentUserHelper
  before_action :set_last_seen_at           # CurrentUserHelper
  before_action :handle_pending_actions     # PendingActionsHelper
  before_action :set_sentry_context
  before_action :ensure_canonical_host

  helper_method :current_user
  helper_method :current_version
  helper_method :bundle_asset_path
  helper_method :supported_locales
  helper_method :is_old_browser?

  after_action :associate_user_to_visit

  def index
    boot_app
  end

  def show
    resource = ModelLocator.new(resource_name, params).locate!
    if current_user.can? :show, resource
      assign_resource
      @pagination = pagination_params
      respond_to do |format|
        format.html
        format.rss  { render :"show.xml" }
        format.xml
      end
    else
      boot_app(status: 403)
    end
  end

  def crowdfunding
    render layout: 'basic'
  end

  def brand
    render layout: 'basic'
  end

  def ok
    head :ok
  end

  protected
  def pagination_params
    { limit: params.fetch(:limit, 100).to_i, offset: params.fetch(:offset, 0).to_i }
  end

  def prevent_caching
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate' # HTTP 1.1.
    response.headers['Pragma'] = 'no-cache' # HTTP 1.0.
    response.headers['Expires'] = '0' # Proxies.
  end

  private

  def ensure_canonical_host
    if ENV['REDIRECT_TO_CANONICAL_HOST']
      if request.host != ENV['CANONICAL_HOST']
        u = URI(request.url)
        u.host = ENV['CANONICAL_HOST']
        redirect_to u.to_s, status: :moved_permanently
      end
    end
  end

  def boot_app(status: 200)
    expires_now
    prevent_caching

    template = File.read(Rails.root.join('public/blient/vue/index.html'))
    color = 'sky gold rock sunset'.split(' ').sample

    logo = File.read(Rails.root.join("public/brand/logo_#{color}.svg"))
    template.gsub!('<img src="/brand/logo_gold.svg">', logo)

    render inline: template, layout: false, status: status
  end

  def redirect_to(url, opts = {})
    return super unless url.is_a? String # GK: for now this override only covers cases where a string has been passed in, so it does not cover cases of a Hash or a Record being passed in
    host = URI(url).host
    if ENV['USE_VUE'] && Rails.env.development? && host == "localhost"
      path = URI(url).path
      query = URI(url).query ? "?#{URI(url).query}" : ""
      super "http://localhost:8080#{path}#{query}"
    else
      super
    end
  end

  def is_old_browser?
    browser.ie? || (browser.safari? && browser.version.to_i < 12)
  end
end
