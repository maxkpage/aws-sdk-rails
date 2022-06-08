require 'aws-sdk-sesv2'

module Aws
  module Rails

    # Provides a delivery method for ActionMailer that uses Amazon Simple Email
    # Service.
    # 
    # Once you have an SES delivery method you can configure Rails to
    # use this for ActionMailer in your environment configuration
    # (e.g. RAILS_ROOT/config/environments/production.rb)
    #
    #     config.action_mailer.delivery_method = :aws_sdk
    #
    # Uses the AWS SDK for Ruby V2's credential provider chain when creating an
    # SES client instance.
    class Mailer

      # @param [Hash] options Passes along initialization options to
      #   [Aws::SES::Client.new](http://docs.aws.amazon.com/sdkforruby/api/Aws/SES/Client.html#initialize-instance_method).
      def initialize(options = {})
        @client = SESV2::Client.new(options)
      end

      # Rails expects this method to exist, and to handle a Mail::Message object
      # correctly. Called during mail delivery.
      def deliver!(message)
        # send_opts = {}
        # send_opts[:raw_message] = {}
        # send_opts[:raw_message][:data] = message.to_s

        # if message.respond_to?(:destinations)
        #   send_opts[:destinations] = message.destinations
        # end

        # @client.send_raw_email(send_opts).tap do |response|
        #   message.header[:ses_message_id] = response.message_id
        # end

        puts "*********"
        puts "*********"
        puts "*********"
        puts "*********"
        puts "Message:"
        puts message.inspect.to_s
        puts "*********"
        puts "*********"
        puts "*********"
        puts "*********"

        # Docs for what to set
        # https://docs.aws.amazon.com/sdk-for-ruby/v2/api/Aws/SESV2/Client.html#send_email-instance_method

        send_opts = {}
        send_opts[:content] = {}
        send_opts[:content][:raw] = { data: message.to_s }

        send_opts[:from_email_address] = message.from&.to_s

        puts "  checking destinations"
        send_opts[:destination] = {}
        send_opts[:destination][:to_addresses] = [message.to].flatten
        send_opts[:destination][:cc_addresses] = [message.cc].flatten unless message.cc.blank?
        send_opts[:destination][:bcc_addresses] = [message.bcc].flatten unless message.bcc.blank?
        #send_opts[:destinations] = message.destinations

        send_opts[:reply_to_addresses] = message.reply_to unless message.reply_to.blank?

        # send_opts[:configuration_set_name] = message.header['X-SES-CONFIGURATION-SET']&.yield_self do |field|
        #   message.header.fields.delete(field).value
        # end

        # send_opts[:list_management_options] = message.header['X-SES-LIST-MANAGEMENT-OPTIONS']&.yield_self do |field|
        #   contact_list_name, topic_name = message.header.fields.delete(field).value.sub("topic=", "").split(";").map(&:strip)
        #   {contact_list_name: contact_list_name, topic_name: topic_name}.compact
        # end

        puts "Send opts:"
        puts send_opts.inspect.to_s
        puts "*********"
        puts "*********"
        puts "*********"
        puts "*********"

        @client.send_email(send_opts).tap do |response|
          message.header[:ses_message_id] = response.message_id
        end
      end

      # ActionMailer expects this method to be present and to return a hash.
      def settings
        {}
      end

    end
  end
end
