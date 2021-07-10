namespace :loomio do
  task generate_test_error: :environment do
    raise "this is a generated test error"
  end

  task :version do
    puts Loomio::Version.current
  end

  task generate_static_error_pages: :environment do
    [400, 404, 403, 410, 417, 422, 429, 500].each do |code|
      ['html'].each do |format|
        File.open("public/#{code}.#{format}", "w") do |f|
          if format == "html"
            f << "<!-- This file is automatically generated by rake loomio:generate_static_error_pages -->\n"
            f << "<!-- Don't make changes here; they will be overwritten. -->\n"
          end
          f << ApplicationController.new.render_to_string(
            locals: {
              '@title': I18n.t("errors.#{code}.title"),
              '@body': I18n.t("errors.#{code}.body"),
            },
            template: "application/error",
            layout: "basic",
            format: format
          )
        end
      end
    end
  end

  task hourly_tasks: :environment do
    PollService.delay.expire_lapsed_polls
    PollService.delay.publish_closing_soon

    if ENV['EMAIL_CATCH_UP_WEEKLY']
      SendWeeklyCatchUpEmailWorker.perform_async
    else
      SendDailyCatchUpEmailWorker.perform_async
    end

    LocateUsersAndGroupsWorker.perform_async
    if (Time.now.hour == 0)
      OutcomeService.delay.publish_review_due
      UsageReportService.send
      ExamplePollService.delay.cleanup
      LoginToken.where("created_at < ?", 24.hours.ago).delete_all
    end
  end

  task generate_error: :environment do
    raise "this is an exception to test exception handling"
  end

  task notify_clients_of_update: :environment do
    MessageChannelService.publish_data({ version: Loomio::Version.current }, to: GlobalMessageChannel.instance)
  end

  task update_subscription_members_counts: :environment do
    SubscriptionService.update_member_counts
  end

  task refresh_expiring_chargify_management_links: :environment do
    # run this once a week
    if Date.today.sunday?
      SubscriptionService.delay.refresh_expiring_management_links
    end
  end

  task populate_chargify_management_links: :environment do
    if Date.today.sunday?
      SubscriptionService.delay.populate_management_links
    end
  end

end
