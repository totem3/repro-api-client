require 'repro/api/client/version'
require 'net/http'
require 'json'
require 'repro/api/request_error'
require 'repro/api/response'

module Repro
  module Api

    class Client

      API_VERSION = 'v1'.freeze
      API_ENDPOINT = "https://marketing.repro.io/#{API_VERSION}".freeze

      attr_reader :options

      def initialize(token, opts = {})
        @options = opts.merge(token: token, method: 'post')
      end

      # /push/:push_id/deliver
      # @param [String] push_id Push ID in Repro
      # @param [Array] user_ids UserIDs to send push notification
      # @option opts [String] :body Message body for push notification. (required)
      # @option opts [String] :title Title for push notification
      # @option opts [Integer] :badge Badge number
      # @option opts [String] :sound Sound file name for notification
      # @option opts [String] :url Custom url or Deep Link
      # @option opts [Hash] :attachment Attachment for rich push. Hash must have keys :type and :url.
      def push_deliver(push_id, user_ids, opts = {})
        raise ArgumentError, ':body is required.' unless opts[:body]
        opts[:path] = "/push/#{push_id}/deliver"
        body = { audience: { user_ids: user_ids } }
        body[:notification] = {custom_payload: build_payload(opts)}
        opts[:body] = body
        send_request(opts)
      end

      def token
        @options[:token]
      end

      def user_agent
        @options[:user_agent] || "Repro Ruby Client/#{VERSION}"
      end

      def endpoint
        @options[:endpoint] || API_ENDPOINT
      end

      private

      def build_payload(opts)
        payload = { aps: { alert: {} }, data: {} }
        payload[:data][:app_body] = opts[:body]
        payload[:data][:app_title] = opts[:title]
        payload[:aps][:alert][:body] = opts[:body]
        payload[:aps][:alert][:title] = opts[:title]
        payload[:aps][:badge] = opts[:badge] if opts[:badge]
        payload[:aps][:sound] = opts.key?(:sound) ? opts[:sound] : 'default'
        if opts[:url]
          payload[:data][:app_url] = opts[:url]
          payload[:rpr_url] = opts[:url]
        end
        if opts[:attachment]
          payload[:data][:app_picture] = {url: opts[:attachment]}
          payload[:aps]['mutable-content'] = 1
          payload[:rpr_attachment] = opts[:attachment]
        end
        JSON.generate(payload)
      end

      def send_request(opts)
        opts = options.merge(opts) if options
        http_response = call_api(opts)
        res = Response.new(http_response)
        unless http_response.is_a? Net::HTTPSuccess
          err_msg = "HTTP Response: #{res.code} #{res.message}"
          err_msg += " - #{res.error}" if res.error
          raise Repro::Api::RequestError, err_msg
        end
        res
      end

      def call_api(opts)
        if opts.delete(:method) == 'post'
          request_url = prepare_url(path: opts.delete(:path))
          request = prepare_request(request_url, body: opts.delete(:body))
          Net::HTTP.start(request_url.host, request_url.port, use_ssl: true) do |http|
            http.request(request)
          end
        else
          request_url = prepare_url(opts)
          Net::HTTP.get_response(request_url)
        end
      end

      def prepare_request(uri, opts)
        request = Net::HTTP::Post.new(uri.path)
        request['Accept'] = 'application/json'
        request['Content-Type'] = 'application/json'
        request['X-Repro-Token'] = token
        request['User-Agent'] = user_agent
        request.body = JSON.generate(opts[:body])
        request
      end

      def prepare_url(opts)
        path = opts.delete(:path)
        query_string = opts.empty? ? '' : '?' + URI.encode_www_form(opts)
        URI.parse(endpoint + path + query_string)
      end

    end

  end
end
