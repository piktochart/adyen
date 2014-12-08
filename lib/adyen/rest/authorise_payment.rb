module Adyen
  module REST

    # This module implements the <b>Payment.authorise</b>, and <b>Payment.authorise3d</b>
    # API calls, and includes a custom response class to make handling the response easier.
    module AuthorisePayment

      # The Response class implements some extensions for the authorise payment call.
      # @see Adyen::REST::Response
      class Response < Adyen::REST::Response

        # Checks whether the authorisation was successful.
        # @return [Boolean] <tt>true</tt> iff the authorisation was successful, and the
        #   authorised amount can be captured.
        def authorised?
          result_code == AUTHORISED
        end

        alias_method :authorized?, :authorised?

        # Checks whether the result of the authorization call was RedirectShopper,
        # which means that the customer has to be redirected away from your site to
        # complete the 3Dsecure transaction.
        # @return [Boolean] <tt>true</tt> iff the shopper has to be redirected,
        #   <tt>false</tt> in any other case.
        def redirect_shopper?
          result_code == REDIRECT_SHOPPER
        end

        private

        AUTHORISED       = 'Authorised'.freeze
        REDIRECT_SHOPPER = 'RedirectShopper'.freeze
        private_constant :AUTHORISED, :REDIRECT_SHOPPER
      end

      # Sends an authorise payment request to Adyen's webservice.
      # @param attributes [Hash] The attributes to include in the request.
      # @return [Adyen::REST::AuthorisePayment::Response] The response from Adyen.
      #   The response responds to <tt>.authorised?</tt> to check whether the
      #   authorization was successful.
      # @see Adyen::REST::AuthorisePayment::Response#authorised?
      def authorise_payment(attributes)
        request = Adyen::REST::Request.new('Payment.authorise', attributes, prefix: 'payment_request')
        execute_api_call(request, Adyen::REST::AuthorisePayment::Response, prefix: 'payment_result')
      end

      alias_method :authorize_payment, :authorise_payment

      # Sends a 3Dsecure-enabled authorise payment request to Adyen's webservice.
      #
      # The response differs based on the credit card uses in the transaction.
      # For some credit cards, an additional offsite step may be required to complete
      # the transaction. Check <tt>.redirect_shopper?</tt> to see if this is the case.
      # Other cards are not 3DSecure-enabled, and may immediately authorise the
      # transaction. Check <tt>.authorised?</tt> to see if this is the case.
      #
      # @param attributes [Hash] The attributes to include in the request.
      # @return [Adyen::REST::AuthorisePayment::Response] The response from Adyen.
      # @see Adyen::REST::AuthorisePayment::Response#redirect_shopper?
      # @see Adyen::REST::AuthorisePayment::Response#authorised?
      def authorise_payment_3dsecure(attributes)
        request = Adyen::REST::Request.new('Payment.authorise3d', attributes, prefix: 'payment_request_3d')
        execute_api_call(request, Adyen::REST::AuthorisePayment::Response, prefix: 'payment_result')
      end

      alias_method :authorize_payment_3dsecure, :authorise_payment_3dsecure
    end
  end
end